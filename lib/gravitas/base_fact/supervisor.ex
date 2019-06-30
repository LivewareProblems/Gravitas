defmodule Gravitas.BaseFact.Supervisor do
  use Supervisor

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(%{repo_name: repo_name} = default) when is_map(default) do
    Supervisor.start_link(__MODULE__, [],
      name: {:via, Registry, {Registry.Gravitas.BaseFacts, repo_name}}
    )
  end

  @impl true
  @spec init(args :: term()) ::
          {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}} | :ignore
  def init(_arg) do
    children = [
      {Gravitas.BaseFactState.Holder, []},
      {Gravitas.BaseFactState.Gatherer, []}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
