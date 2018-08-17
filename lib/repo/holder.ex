defmodule Gravitas.Repo.Holder do
  use GenServer
  alias Gravitas.Repo.Git

  @moduledoc """
  This server hold a git repo in our app, through its path stored in the state
  """
  @spec start_link([Path.t()]) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @spec update_repo() :: any()
  def update_repo() do
    GenServer.cast(__MODULE__, :update)
  end

  @impl true
  @spec init(Path.t()) :: {:ok, Path.t()}
  def init(path) do
    {:ok, path}
  end

  @impl true
  @spec handle_cast(
          :update,
          Path.t()
        ) :: {:noreply, Path.t()}
  def handle_cast(:update, path) do
    Git.fetch(path)
    {:noreply, path}
  end
end
