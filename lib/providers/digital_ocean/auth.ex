defmodule Gravitas.Providers.DigitalOcean.Auth do
  def headers(headers, config) do
    [{"Authorization", "Bearer " <> config[:do_oauth_token]} | headers]
  end
end
