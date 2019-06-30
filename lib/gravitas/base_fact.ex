defmodule Gravitas.BaseFact do
  @moduledoc """
  to be used for the BaseFact.Holder state
  """
  defstruct ec2: [],
            do: []

  @type t :: %Gravitas.BaseFact{ec2: [], do: []}
end