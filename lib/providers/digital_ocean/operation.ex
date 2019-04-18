defmodule Gravitas.Providers.DigitalOcean.Operation do
  defstruct http_method: :post,
            parser: nil,
            path: "/",
            data: %{},
            params: %{},
            headers: [{"Content-Type", "application/json"}]

  @type t :: %__MODULE__{}

  @spec new(Enum.t()) :: %__MODULE__{}
  def new(opts \\ []) do
    struct(%__MODULE__{}, opts)
  end
end
