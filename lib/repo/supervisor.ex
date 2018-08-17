defmodule Gravitas.Repo.Supervisor do
  use Supervisor

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  @spec init(args :: term()) ::
          {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}} | :ignore
  def init(_arg) do
    repo_path = List.first(Application.get_env(:gravitas, :repo_path_list))

    children = [
      {Gravitas.Repo.Holder, [repo_path]},
      {Gravitas.Repo.Updater, []}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
