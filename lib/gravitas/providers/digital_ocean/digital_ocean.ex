defmodule Gravitas.Providers.DigitalOcean do
  def request(method, url, data, headers \\ [], config \\ []) do
    body =
      case data do
        [] -> "{}"
        d when is_binary(d) -> d
        _ -> Jason.encode!(data)
      end

    request_and_retry(method, url, config, headers, body, {:attempt, 1})
  end

  def request_and_retry(_method, _url, _config, _headers, _req_body, {:error, reason}) do
    {:error, reason}
  end

  def request_and_retry(method, url, config, headers, req_body, {:attempt, attempt}) do
    full_headers = Gravitas.Providers.DigitalOcean.Auth.headers(headers, config)

    with {:ok, full_headers} <- full_headers do
      safe_url = URI.encode(url)

      case hackney_request(
             method,
             safe_url,
             req_body,
             full_headers,
             Map.get(config, :http_opts, [])
           ) do
        {:ok, %{status_code: status} = resp} when status in 200..299 or status == 304 ->
          {:ok, resp}

        {:ok, %{status_code: status} = _resp} when status == 301 ->
          {:error, {:http_error, status, "redirected"}}

        {:ok, %{status_code: status} = resp} when status in 400..499 ->
          {:error, resp}

        {:ok, %{status_code: status} = resp} when status >= 500 ->
          body = Map.get(resp, :body)
          reason = {:http_error, status, body}

          request_and_retry(
            method,
            url,
            config,
            headers,
            req_body,
            attempt_again?(attempt, reason, config)
          )

        {:error, %{reason: reason}} ->
          request_and_retry(
            method,
            url,
            config,
            headers,
            req_body,
            attempt_again?(attempt, reason, config)
          )
      end
    end
  end

  def perform(operation, config) do
    url = build(operation, config)

    headers = operation.headers

    request(
      operation.http_method,
      url,
      operation.data,
      headers,
      config
    )
  end

  @default_opts [recv_timeout: 30_000]

  def hackney_request(method, url, body \\ "", headers \\ [], http_opts \\ []) do
    opts =
      Application.get_env(:gravitas, :do_options, %{})
      |> Map.get(:hackney_opts, @default_opts)

    opts = http_opts ++ [:with_body | opts]

    case :hackney.request(method, url, headers, body, opts) do
      {:ok, status, headers} ->
        {:ok, %{status_code: status, headers: headers}}

      {:ok, status, headers, body} ->
        {:ok, %{status_code: status, headers: headers, body: body}}

      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

  @doc """
  Builds URL for an operation and a config"
  """
  def build(operation, config) do
    config
    |> Map.take([:scheme, :host, :port])
    |> Map.put(:query, query(operation))
    |> Map.put(:path, operation.path)
    |> normalize_scheme
    |> normalize_path
    |> convert_port_to_integer
    |> (&struct(URI, &1)).()
    |> URI.to_string()
    |> String.trim_trailing("?")
  end

  defp query(operation) do
    operation
    |> Map.get(:params, %{})
    |> normalize_params
    |> URI.encode_query()
  end

  defp normalize_scheme(url) do
    url |> Map.update(:scheme, "", &String.replace(&1, "://", ""))
  end

  defp normalize_path(url) do
    url |> Map.update(:path, "", &String.replace(&1, ~r/\/{2,}/, "/"))
  end

  defp convert_port_to_integer(url = %{port: port}) when is_binary(port) do
    {port, _} = Integer.parse(port)
    put_in(url[:port], port)
  end

  defp convert_port_to_integer(url), do: url

  defp normalize_params(params) when is_map(params) do
    params |> Map.delete("") |> Map.delete(nil)
  end

  defp normalize_params(params), do: params

  def attempt_again?(attempt, reason, config) do
    if attempt >= config[:retries][:max_attempts] do
      {:error, reason}
    else
      attempt |> backoff(config)
      {:attempt, attempt + 1}
    end
  end

  def backoff(attempt, config) do
    (config[:retries][:base_backoff_in_ms] * :math.pow(2, attempt))
    |> min(config[:retries][:max_backoff_in_ms])
    |> trunc
    |> :rand.uniform()
    |> :timer.sleep()
  end

  def get_paginated_data(operation, key, config, results) do
    with {:ok, resp} <- perform(operation, config),
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
