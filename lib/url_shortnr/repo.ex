defmodule UrlShortnr.Repo do
  use Ecto.Repo,
    otp_app: :url_shortnr,
    adapter: Ecto.Adapters.SQLite3
end
