defmodule Gravitas.Project do
  @moduledoc """
  main interface for interfacing with Projects
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

  @spec force_update(String.t(), event_type()) :: any()
  def force_update(repo_name, event_type) do
    send({:via, Registry, {Registry.Gravitas.Repos, repo_name}}, {:fetch, event_type})
  end
end
