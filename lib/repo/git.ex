defmodule Gravitas.Repo.Git do
  @moduledoc """
  This is used to give a nice API for our use of Git
  """
  @spec fetch(Path.t()) :: {any(), non_neg_integer()}
  def fetch(path) do
    System.cmd("git", ["fetch", "--force", "--quiet"],
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: true,
      cd: Path.expand(path)
    )
  end
end
