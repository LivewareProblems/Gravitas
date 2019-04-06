defmodule Gravitas.Providers.DigitalOcean.Operation do
  defstruct http_method: :post,
            parser: nil,
            path: "/",
            data: %{},
            params: %{},
            headers: []

  @type t :: %__MODULE__{}

  def new(opts \\ []) do
    struct(%__MODULE__{}, opts)
  end
end
