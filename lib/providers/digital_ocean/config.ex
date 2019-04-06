defmodule Gravitas.Providers.DigitalOcean.Config do
  def new(override_opts \\ []) do
    overrides = Map.new(override_opts)

    do_options = Application.get_env(:gravitas, :do_options, []) |> Map.new()
    Map.merge(do_options, overrides)
  end
end
