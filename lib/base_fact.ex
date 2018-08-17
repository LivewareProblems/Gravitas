defmodule Gravitas.BaseFact do
  @moduledoc """
  to be used for the BaseFact.Holder state
  """
  defstruct ec2: []

  @type t :: %Gravitas.BaseFact{ec2: []}
end
