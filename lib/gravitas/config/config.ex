defmodule Gravitas.Config do
  @spec local_store() :: Path.t()
  def local_store() do
    Application.get_env(:gravitas, :local_git_store)
  end
end
