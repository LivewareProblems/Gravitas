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
  @spec init(any()) :: {:ok, %{ec2: nil}, {:continue, :ec2}}
  def init(_args) do
    {:ok, %{ec2: nil}, {:continue, :ec2}}
  end

  @impl true
  @spec handle_continue(:ec2, %{ec2: any()}) :: {:noreply, %{ec2: nil | [{any(), any()}] | map()}}
  def handle_continue(:ec2, state) do
    ec2_instances = update_ec2_instances()
    schedule_fetch()
    {:noreply, %{state | ec2: ec2_instances}}
  end

  @impl true
  def handle_info({:describe, :ec2}, state) do
    ec2_instances = update_ec2_instances()
    schedule_fetch()
    {:noreply, %{state | ec2: ec2_instances}}
  end

  defp schedule_fetch(interval \\ 60_000_000) do
    Process.send_after(self(), {:describe, :ec2}, interval)
  end

  defp update_ec2_instances() do
    {:ok, ec2_content} = ExAws.EC2.describe_instances() |> ExAws.request()
    {:ok, ec2_instances} = Poison.decode(ec2_content[:body])
    Gravitas.BaseFact.Holder.update_ec2(ec2_instances["regionInfo"])
    ec2_instances
  end
end
