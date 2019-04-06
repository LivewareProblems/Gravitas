defmodule Gravitas.BaseFact.Gatherer do
  use GenServer

  @moduledoc """
    This server schedule when to gather fact from Cloud ressources,
    do so and then update the state
  """
  @spec start_link([]) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default)
  end

  @impl true
  @spec init(any()) :: {:ok, :DO, {:continue, :DO}}
  def init(_args) do
    {:ok, :DO, {:continue, :DO}}
  end

  @impl true
  @spec handle_continue(:DO, :DO) :: {:noreply, :DO}
  def handle_continue(:DO, _state) do
    DO_instances = update_DO_instances()
    schedule_fetch()
    {:noreply, :DO}
  end

  @impl true
  def handle_info({:describe, :DO}, _state) do
    DO_instances = update_DO_instances()
    schedule_fetch()
    {:noreply, :DO}
  end

  defp schedule_fetch(interval \\ 60_000_000) do
    Process.send_after(self(), {:describe, :DO}, interval)
  end

  defp update_DO_instances() do
    {:ok, do_droplets} = Gravitas.Providers.DigitalOcean.Droplets.list_all_droplets()
    Gravitas.BaseFact.Holder.update_DO(do_droplets)
    do_droplets
  end
end
