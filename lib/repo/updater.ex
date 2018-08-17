defmodule Gravitas.Repo.Updater do
  use GenServer

  @moduledoc """
  This server schedule an event to update the git repo state
  This even is handled by a Gravitas.Repo.Holder
  """
  @spec start_link([]) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default)
  end

  @impl true
  @spec init(any()) :: {:ok, any(), {:continue, :git}}
  def init(_args) do
    {:ok, [], {:continue, :git}}
  end

  @impl true
  @spec handle_continue(:git, any()) :: {:noreply, any()}
  def handle_continue(:git, state) do
    Gravitas.Repo.Holder.update_repo()
    schedule_fetch()
    {:noreply, state}
  end

  @impl true
  def handle_info({:fetch, :git}, state) do
    Gravitas.Repo.Holder.update_repo()
    schedule_fetch()
    {:noreply, state}
  end

  defp schedule_fetch(interval \\ 120_000) do
    Process.send_after(self(), {:fetch, :git}, interval)
  end
end
