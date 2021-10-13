defmodule UrlShortnrWeb.ShortLinkLive.Index do
  use UrlShortnrWeb, :live_view

  alias UrlShortnr.ShortLinks
  alias UrlShortnr.ShortLinks.ShortLink

  @impl true
  def mount(params, session, socket) do


    {:ok, assign(socket, :short_links, list_short_links())}
  end

  @impl true
  def handle_params(params, url, socket) do
    # https://github.com/phoenixframework/phoenix_live_view/issues/1389#issuecomment-808879444
    parsed_url = URI.parse(url)
    app_url = "#{parsed_url.scheme}://#{parsed_url.host}:#{parsed_url.port}"

    socket =
      socket
      |> assign(app_url: app_url)
      |> apply_action(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Short link")
    |> assign(:short_link, ShortLinks.get_short_link!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Short link")
    |> assign(:short_link, %ShortLink{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Short links")
    |> assign(:short_link, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    short_link = ShortLinks.get_short_link!(id)
    {:ok, _} = ShortLinks.delete_short_link(short_link)

    {:noreply, assign(socket, :short_links, list_short_links())}
  end

  defp list_short_links do
    ShortLinks.list_short_links()
  end
end
