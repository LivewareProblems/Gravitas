defmodule Gravitas.Providers.DigitalOcean.Auth do
  @spec headers(list(), nil | map()) :: {:ok, list()}
  def headers(headers, config) do
    {:ok, [{"Authorization", "Bearer " <> config[:do_oauth_token]} | headers]}
  end
end
