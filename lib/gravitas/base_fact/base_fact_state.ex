defmodule Gravitas.BaseFactState do
  @moduledoc """
  to be used for the BaseFact.Holder state
  """
  defstruct ec2: [],
            do: []

  @type t :: %Gravitas.BaseFactState{ec2: [], do: []}
end
