defmodule Gravitas.Project.BaseFactsSupervisor do
  use DynamicSupervisor

  @moduledoc """
  Supervisor to launch BaseFacts for a project
  """
  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @spec start_child({Gravitas.BaseFact.Supervisor, [...]}) :: DynamicSupervisor.on_start_child()
  def start_child(spec) do
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @spec terminate_child(String.t()) :: :ok | {:error, :not_found}
  def terminate_child(name) do
    # technically we have a race condition here... what to do ?
    [{pid, _value}] = Registry.lookup(Registry.Gravitas.BaseFacts, name)
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  @impl true
  @spec init([DynamicSupervisor.init_option()]) :: {:ok, DynamicSupervisor.sup_flags()}
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
