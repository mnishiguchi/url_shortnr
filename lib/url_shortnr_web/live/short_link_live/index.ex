defmodule UrlShortnrWeb.ShortLinkLive.Index do
  use UrlShortnrWeb, :live_view

  alias UrlShortnr.ShortLinks
  alias UrlShortnr.ShortLinks.ShortLink
  alias UrlShortnr.ShortLinks.PubSub

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe()
    end

    socket = assign(socket, :short_links, list_short_links())

    {:ok, socket, temporary_assigns: [short_links: []]}
  end

  @impl true
  def handle_params(params, url, socket) do
    socket =
      socket
      |> assign_url(url)
      |> apply_action(socket.assigns.live_action, params)

    {:noreply, socket}
  end

  defp assign_url(socket, url) do
    # https://github.com/phoenixframework/phoenix_live_view/issues/1389#issuecomment-808879444
    parsed_url = URI.parse(url)
    app_url = "#{parsed_url.scheme}://#{parsed_url.host}:#{parsed_url.port}"

    socket
    |> assign(app_url: app_url)
    |> assign(current_path: parsed_url.path)
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

  ## UI events

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    short_link = ShortLinks.get_short_link!(id)
    {:ok, _} = ShortLinks.delete_short_link(short_link)

    {:noreply, assign(socket, :short_links, list_short_links())}
  end

  ## PubSub

  @impl true
  def handle_info({:short_link_inserted, new_short_link}, socket) do
    socket = update(socket, :short_links, &[new_short_link | &1])
    {:noreply, socket}
  end

  @impl true
  def handle_info({:short_link_updated, updated_short_link}, socket) do
    socket = update(socket, :short_links, &[updated_short_link | &1])
    {:noreply, socket}
  end

  @impl true
  def handle_info({:short_link_deleted, deleted_short_link}, socket) do
    # Let JS remove the row because temporary_assigns with phx-update won't delete an item.
    socket = push_event(socket, "short_link_deleted", %{id: deleted_short_link.id})
    {:noreply, socket}
  end

  ## Utils

  defp list_short_links do
    ShortLinks.list_short_links()
  end
end
