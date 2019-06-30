defmodule Gravitas.Repo.Holder do
  use GenServer

  @moduledoc """
  This server hold a DETS table with all the git repo in our app
  A row store the following things
  {name_used_in_gravitas, remote path, event_type, :init | :ready | :remove}
  If a new row is added, it starts an event generator process named
  "name_used_in_gravitas". Once a repo is cloned succesfuly we expect the
  event generator to come back and ask to put the state in :ready.
  A repo can be removed, which delete the event generator then remove the repo
  from disk and then remove the row of the repo.
  """

  @type repo_row ::
          {Path.t(), String.t(), Gravitas.Project.event_type(), :init | :ready | :remove}

  @spec start_link(Path.t()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(default) do
    GenServer.start_link(__MODULE__, %{dir_path: default, name: __MODULE__}, name: __MODULE__)
  end

  @spec add_repo(String.t(), Gravitas.Project.event_type()) :: any()
  def add_repo(remote_path, type) do
    GenServer.call(__MODULE__, {:add, remote_path, type})
  end

  @spec ready_repo(Path.t()) :: any()
  def ready_repo(repo_name) do
    GenServer.call(__MODULE__, {:ready, repo_name})
  end

  @spec remove_repo(Path.t()) :: any()
  def remove_repo(repo_name) do
    GenServer.cast(__MODULE__, {:remove, repo_name})
  end

  @impl true
  @spec init(%{name: atom, dir_path: Path.t()}) ::
          {:ok, :dets.tab_name(), {:continue, :load_existing}}
  def init(%{name: name, dir_path: dir_path}) do
    erlang_file_name =
      dir_path
      |> Path.join("repo_holder.dets")
      |> String.to_charlist()

    {:ok, dets_name} = :dets.open_file(name, [{:file, erlang_file_name}])
    {:ok, dets_name, {:continue, :load_existing}}
  end

  @impl true
  @spec handle_continue(:load_existing, :dets.tab_name()) :: {:noreply, :dets.tab_name()}
  def handle_continue(:load_existing, dets_name) do
    dets_name
    |> :dets.match_object(:"$1")
    |> Enum.map(&start_repo(&1, dets_name))

    {:noreply, dets_name}
  end

  @impl true
  def handle_call({:add, remote_path, event_type}, _from, dets_name) do
    local_path =
      remote_path
      |> String.split(":", trim: true)
      |> List.last()

    :dets.insert(dets_name, {local_path, remote_path, event_type, :init})

    Gravitas.Repo.EventGenerator.start_event_generator(%{
      type: event_type,
      remote_path: remote_path,
      repo_name: local_path
    })

    Gravitas.BaseFact.start_base_fact(%{repo_name: local_path})
    {:reply, :ok, dets_name}
  end

  @impl true
  def handle_call({:ready, repo_name}, _from, dets_name) do
    [{^repo_name, remote_name, event_type, status}] = :dets.lookup(dets_name, repo_name)
    :ok = :dets.insert(dets_name, {repo_name, remote_name, event_type, :ready})

    if status == :removed do
      remove_repo(repo_name)
    end

    {:reply, :ok, dets_name}
  end

  @impl true
  def handle_cast({:remove, repo_name}, dets_name) do
    [{repo_name, remote_name, event_type, status}] = :dets.lookup(dets_name, repo_name)

    case status do
      :ready ->
        Gravitas.Repo.EventGenerator.terminate_event_generator(repo_name)
        :dets.delete(dets_name, repo_name)

      :removed ->
        :ok

      :init ->
        :ok = :dets.insert(dets_name, {repo_name, remote_name, event_type, :removed})
    end

    {:noreply, dets_name}
  end

  defp start_repo({local_path, remote_path, event_type, _state}, dets_name) do
    :dets.insert(dets_name, {local_path, remote_path, event_type, :init})

    Gravitas.Repo.EventGenerator.start_event_generator(%{
      type: event_type,
      remote_path: remote_path,
      repo_name: local_path
    })
  end
end
