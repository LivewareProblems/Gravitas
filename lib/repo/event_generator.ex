defmodule Gravitas.Repo.EventGenerator do
  use GenServer
  alias Gravitas.Repo

  @moduledoc """
  There is one of these servers for every repo handled by this node
  They serialise every event happening on a repo. That means that even
  Job Plan regeneration go through them, to avoid race conditions

  Note: Regenerating Job Plan should be a blocking call, to avoid race conditions
  """
  @type state() :: %{repo_name: Path.t(), type: Repo.event_type(), remote_path: String.t()}

  @spec start_link(state()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(%{repo_name: repo_name} = default) when is_map(default) do
    GenServer.start_link(__MODULE__, default,
      name: {:via, Registry, {Registry.Gravitas, repo_name}}
    )
  end

  @spec start_event_generator(Repo.EventGenerator.state()) :: DynamicSupervisor.on_start_child()
  def start_event_generator(state) do
    spec = {Repo.EventGenerator, [state]}
    Repo.EventSupervisor.start_child(spec)
  end

  @spec terminate_event_generator(String.t()) :: :ok | {:error, :not_found}
  def terminate_event_generator(repo_name) do
    Repo.EventSupervisor.terminate_child(repo_name)
  end

  @impl true
  @spec init(state()) :: {:ok, state(), {:continue, state()}}
  def init(%{type: :git} = state) do
    {:ok, state, {:continue, state}}
  end

  @impl true
  @spec handle_continue(state(), state()) :: {:noreply, state()}
  def handle_continue(%{type: :git, repo_name: repo_name, remote_path: remote_path}, state) do
    Repo.Git.checkout(repo_name, remote_path)
    Repo.Holder.ready_repo(repo_name)
    schedule_fetch(:git)
    {:noreply, state}
  end

  @impl true
  def handle_info({:fetch, :git}, %{repo_name: repo_name, remote_path: remote_path} = state) do
    Repo.Git.checkout(repo_name, remote_path)
    schedule_fetch(:git)
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, %{repo_name: repo_name, type: :git}) do
    Repo.Git.cleanup(repo_name)
  end

  defp schedule_fetch(type, interval \\ 300_000) do
    Process.send_after(self(), {:fetch, type}, interval)
  end
end
