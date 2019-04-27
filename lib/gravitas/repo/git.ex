defmodule Gravitas.Repo.Git do
  @moduledoc """
  This is used to give a nice API for our use of Git
  """
  @spec checkout(Path.t(), String.t()) :: :ok | no_return
  def checkout(repo_name, remote_path) do
    path = local_path(repo_name)

    File.rm_rf!(path)
    File.mkdir_p!(path)

    File.cd!(path, fn ->
      git!(["init", "--quiet"])
      git!(["--git-dir=.git", "remote", "add", "origin", remote_path])
      git!(["--git-dir=.git", "fetch", "--force", "--quiet"])
      git!(["--git-dir=.git", "checkout", "--quiet", "origin/master"])
    end)
  end

  @spec cleanup(Path.t()) :: [binary()]
  def cleanup(repo_name) do
    repo_name
    |> local_path()
    |> File.rm_rf!()
  end

  defp git!(args) do
    case System.cmd("git", args, into: IO.stream(:stdio, :line), stderr_to_stdout: true) do
      {response, 0} -> response
    end
  end

  defp local_path(repo_name) do
    Gravitas.Config.local_store()
    |> Path.join(repo_name)
  end
end
