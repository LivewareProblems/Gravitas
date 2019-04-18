defmodule Gravitas.Providers.DigitalOcean.Droplets do
  alias Gravitas.Providers.DigitalOcean

  @spec list_all_droplets([list()]) :: {:error, any()} | {:ok, any()}
  def list_all_droplets(override_opts \\ []) do
    operation =
      DigitalOcean.Operation.new()
      |> Map.put(:path, "/v2/droplets")
      |> Map.put(:http_method, :get)

    do_config = DigitalOcean.Config.new(override_opts)

    case get_paginated_data(operation, "region_info", do_config, []) do
      {:ok, list_resp} -> {:ok, list_resp}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec get_droplets_by_id(integer() | String.t(), list()) :: {:error, any()} | {:ok, any()}
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

  def get_paginated_data(operation, key, config, results) do
    with {:ok, resp} <- DigitalOcean.perform(operation, config),
         body <- Jason.decode!(resp[:body]) do
      body_key_results = Map.get(body, key, [])

      case body do
        %{"links" => %{"next" => next_link}} ->
          with %URI{} = uri <- URI.parse(next_link),
               query_params <- URI.decode_query(uri.query),
               do_config <- Map.merge(config, uri) |> Map.put(:params, query_params) do
            get_paginated_data(operation, key, do_config, [results, body_key_results])
          else
            error -> error
          end

        %{"links" => _links} ->
          {:ok, List.flatten(results, body_key_results)}

        _ ->
          {:ok, body_key_results}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
