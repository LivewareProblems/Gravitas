defmodule Gravitas.BaseFact.Holder do
  use GenServer

  @moduledoc """
  Hold the state described by gathering Cloud ressources facts
  """
  @spec start_link([]) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @spec update_ec2(any()) :: any()
  def update_ec2(ec2_state) do
    GenServer.call(__MODULE__, {:ec2_update, ec2_state})
  end

  @spec update_DO(any()) :: any()
  def update_DO(do_region_info) do
    GenServer.call(__MODULE__, {:do_update, do_region_info})
  end

  @spec add_droplet(map()) :: any
  def add_droplet(droplet_data) do
    GenServer.call(__MODULE__, {:add_droplet, droplet_data})
  end

  @impl true
  @spec init(any()) :: {:ok, Gravitas.BaseFactState.t()}
  def init(_args) do
    {:ok, %Gravitas.BaseFactState{}}
  end

  @impl true
  def handle_call({:ec2_update, ec2_state}, _from, state) do
    {:reply, :ok, %{state | ec2: ec2_state}}
  end

  @impl true
  def handle_call({:do_update, do_state}, _from, state) do
    {:reply, :ok, %{state | do: do_state}}
  end

  @impl true
  def handle_call({:add_droplet, droplet}, _from, state) do
    new_state = %{state | do: Enum.uniq_by([droplet | state[:do]], &Map.fetch!(&1, "id"))}
    {:reply, :ok, new_state}
  end
end
