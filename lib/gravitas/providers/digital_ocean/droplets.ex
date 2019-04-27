defmodule Gravitas.Providers.DigitalOcean.Droplets do
  alias Gravitas.Providers.DigitalOcean

  @spec list_all_droplets([list()]) :: {:error, any()} | {:ok, any()}
  def list_all_droplets(override_opts \\ []) do
    operation =
      DigitalOcean.Operation.new()
      |> Map.put(:path, "/v2/droplets")
      |> Map.put(:http_method, :get)

    do_config = DigitalOcean.Config.new(override_opts)

    case DigitalOcean.get_paginated_data(operation, "region_info", do_config, []) do
      {:ok, list_resp} -> {:ok, list_resp}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec get_droplets_by_id(integer() | String.t(), keyword()) :: {:error, any()} | {:ok, any()}
  def get_droplets_by_id(id, override_opts \\ []) do
    operation =
      DigitalOcean.Operation.new()
      |> Map.put(:path, "/v2/droplets/" <> to_string(id))
      |> Map.put(:http_method, :get)

    case DigitalOcean.perform(operation, DigitalOcean.Config.new(override_opts)) do
      {:ok, resp} -> {:ok, Jason.decode!(resp[:body]) |> Map.get("droplet", %{})}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec create_droplet(map(), keyword) :: {:error, any()} | {:ok, map()}
  def create_droplet(droplet_data, override_opts \\ []) do
    operation =
      DigitalOcean.Operation.new()
      |> Map.put(:path, "/v2/droplets/")
      |> Map.put(:http_method, :post)
      |> Map.put(:data, droplet_data)

    case DigitalOcean.perform(operation, DigitalOcean.Config.new(override_opts)) do
      {:ok, resp} -> {:ok, Jason.decode!(resp[:body]) |> Map.get("droplet", %{})}
      {:error, reason} -> {:error, reason}
    end
  end
end
