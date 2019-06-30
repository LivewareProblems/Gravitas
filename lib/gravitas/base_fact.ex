defmodule Gravitas.BaseFact do
  alias Gravitas.BaseFact

  @spec start_base_fact(%{repo_name: String.t()}) :: DynamicSupervisor.on_start_child()
  def start_base_fact(default) when is_map(default) do
    spec = {BaseFact.Supervisor, [default]}
    Gravitas.Project.BaseFactsSupervisor.start_child(spec)
  end
end
