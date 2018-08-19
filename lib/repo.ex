defmodule Gravitas.Repo do
  @moduledoc """
  main interface for interfacing with Repos
  """
  alias Gravitas.Repo
  @type event_type :: :git

  @spec add_repo(String.t(), event_type()) :: any()
  def add_repo(remote_path, type \\ :git) do
    Repo.Holder.add_repo(remote_path, type)
  end

  @spec delete_repo(String.t()) :: :ok
  def delete_repo(repo_name) do
    Repo.Holder.remove_repo(repo_name)
  end
end
