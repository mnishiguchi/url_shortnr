defmodule UrlShortnr.Repo do
  use Ecto.Repo,
    otp_app: :url_shortnr,
    adapter:
      if(Mix.env() in [:dev, :test],
        do: Ecto.Adapters.SQLite3,
        else: Ecto.Adapters.Postgres
      )
end
