defmodule UrlShortnrWeb.ShortLinkRedirectController do
  use UrlShortnrWeb, :controller

  alias UrlShortnr.ShortLinks

  # GET /:key
  # Redirect to the registered URL for a given key.
  def index(conn, %{"key" => key}) do
    case ShortLinks.get_short_link_by_key(key) do
      nil ->
        conn
        |> put_flash(:error, "Invalid short link")
        |> redirect(to: "/")

      short_link ->
        Task.start(fn -> ShortLinks.increment_hit_count(short_link) end)
        redirect(conn, external: short_link.url)
    end
  end
end
