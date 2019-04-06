defmodule Gravitas.Providers.DigitalOcean.Droplets do
  alias Gravitas.Providers.DigitalOcean

  def list_all_droplets(override_opts \\ []) do
    operation =
      DigitalOcean.Operation.new()
      |> Map.put(:path, "/v2/droplets")
      |> Map.put(:http_method, :get)

    case DigitalOcean.perform(operation, DigitalOcean.Config.new(override_opts)) do
      {:ok, resp} -> Jason.decode!(resp) |> Map.get("region_info", [])
      {:error, reason} -> {:error, reason}
    end
  end
end
