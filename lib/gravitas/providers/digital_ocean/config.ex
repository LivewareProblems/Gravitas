defmodule Gravitas.Providers.DigitalOcean.Config do
  @spec new(list()) :: map()
  def new(override_opts \\ []) do
    overrides = Map.new(override_opts)

    %{
      scheme: "https://",
      host: "api.digitalocean.com",
      port: 443
    }
    |> Map.merge(Application.get_env(:gravitas, :do_options, []) |> Map.new())
    |> Map.merge(overrides)
  end
end
