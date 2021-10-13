defmodule UrlShortnrWeb.ShortLinkLive.Index do
  use UrlShortnrWeb, :live_view

  alias UrlShortnr.ShortLinks
  alias UrlShortnr.ShortLinks.ShortLink

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :short_links, list_short_links())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
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
