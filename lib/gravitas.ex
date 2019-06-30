defmodule Gravitas do
  use Application

  @moduledoc """
  Documentation for Gravitas.

  This is the Manager of Gravitas.

  Gravitas is a cloud provisioning tool, that allows to provision cloud ressources
  declared in a Dhall input. Gravitas also maintain and enforce that state of
  provisioning.

  The Manager is responsible for handling the state of the ressources, receiving
  new declarations, start the Planner and pass it all the data needed to compute
  the job plan, and execute the job plan.

  Gravitas can handle multiple environment and workspaces. Each workspace is expected
  to be hold in its own git repository.

  Gravitas is made of different parts:
  * `Gravitas.Project`: Interface with the git repository of target state
  * `Gravitas.Providers`: Interface with the code interacting with cloud vendors
  * `Gravitas.BaseFactState`: Interface with the state of the cloud ressources as Gravitas know them
  """

  @doc false
  @spec start(any(), any()) :: {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Registry.Gravitas.Repos},
      {Registry, keys: :unique, name: Registry.Gravitas.BaseFacts},
      {Gravitas.Project.Supervisor, []},
      {Gravitas.BaseFactState.Supervisor, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
