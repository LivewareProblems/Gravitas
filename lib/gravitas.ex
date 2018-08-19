defmodule Gravitas do
  use Application

  @moduledoc """
  Documentation for Gravitas.
  """

  @spec start(any(), any()) :: {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Registry.Gravitas},
      {Gravitas.Repo.Supervisor, []},
      {Gravitas.BaseFact.Supervisor, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
