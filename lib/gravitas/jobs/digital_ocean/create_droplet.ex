defmodule Gravitas.DigitalOcean.CreateDroplet do
  alias Gravitas.Providers.DigitalOcean.Droplets

  @behaviour :gen_statem

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(droplet_data) do
    :gen_statem.start_link(__MODULE__, droplet_data, [])
  end

  @spec init(map) :: {:ok, :act, map}
  def init(droplet_data) do
    {:ok, :act, droplet_data}
  end

  @spec callback_mode :: [:state_enter | :state_functions, ...]
  def callback_mode() do
    [:state_functions, :state_enter]
  end

  @spec act(:enter, any, map) :: {:next_state, :valid?, map} | {:next_state, :error, []}
  def act(:enter, _old_state, data) do
    case Droplets.create_droplet(data) do
      {:ok, data} -> {:next_state, :valid?, data}
      _ -> {:next_state, :error, []}
    end
  end

  @spec valid?(:enter, any, map) :: {:next_state, :store | :wait, map}
  def valid?(:enter, _old_state, created_droplet) do
    case created_droplet do
      %{"status" => "active"} -> {:next_state, :store, created_droplet}
      _ -> {:next_state, :wait, created_droplet}
    end
  end

  @spec wait(:enter | :state_timeout, :valid?, map) ::
          {:next_state, :error | :valid?, map}
          | {:next_state, :wait, map, [{:state_timeout, 60000, :valid?}, ...]}
  def wait(:enter, :valid?, created_droplet) do
    {:next_state, :wait, created_droplet, [{:state_timeout, 60_000, :valid?}]}
  end

  def wait(:state_timeout, :valid?, created_droplet) do
    case Droplets.get_droplets_by_id(created_droplet["id"]) do
      {:ok, new_droplet} -> {:next_state, :valid?, new_droplet}
      _ -> {:next_state, :error, []}
    end
  end

  @spec store(:enter, :valid?, map) :: {:next_state, :done, []}
  def store(:enter, :valid?, created_droplet) do
    Gravitas.BaseFact.Holder.add_droplet(created_droplet)
    {:next_state, :done, []}
  end

  @spec done(:enter, :store, any) :: :stop
  def done(:enter, :store, _data) do
    :stop
  end

  @spec error(:enter, :wait, any) :: :stop
  def error(:enter, :wait, _data) do
    :stop
  end
end
