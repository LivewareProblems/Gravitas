defmodule Gravitas.Project.Supervisor do
  use Supervisor

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  @spec init(args :: term()) ::
          {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}} | :ignore
  def init(_arg) do
    repo_path =
      Application.get_env(
        :gravitas,
        :table_repo_state_path,
        Application.app_dir(:gravitas, "priv")
      )

    children = [
      {Gravitas.Repo.Holder, [repo_path]},
      {Gravitas.Project.ReposSupervisor, []},
      {Gravitas.Project.BaseFactsSupervisor, []}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
