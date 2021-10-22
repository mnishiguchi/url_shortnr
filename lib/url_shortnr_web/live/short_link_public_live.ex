defmodule UrlShortnrWeb.ShortLinkPublicLive do
  use UrlShortnrWeb, :live_view

  alias UrlShortnr.ShortLinks
  alias UrlShortnr.ShortLinks.PubSub

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      PubSub.subscribe()
    end

    socket =
      socket
      |> assign_current_user(session)
      |> assign(:short_links, list_short_links())

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

    app_url =
      if Application.get_env(:url_shortnr, :env) in [:dev, :test] do
        "http://#{parsed_url.host}:#{parsed_url.port}"
      else
        "https://#{parsed_url.host}"
      end

    socket
    |> assign(app_url: app_url)
    |> assign(current_path: parsed_url.path)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:short_link, nil)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%= live_component(@socket, UrlShortnrWeb.ShortLinkPublicLive.FormComponent,
      id: :stateful,
      action: @live_action) %>

    <table>
      <thead>
        <tr>
          <th>Destination</th>
          <th>Shortened URL</th>
          <th>Hits</th>
        </tr>
      </thead>
      <tbody id="short_links" phx-update="prepend" phx-hook="ShortLinkTable">
        <%= for short_link <- @short_links do %>
          <tr id={"short_link-#{short_link.id}"}>
            <td style="overflow-x:auto;max-width:33vw"><%= short_link.url %></td>
            <% shortened_url = "#{@app_url}/#{short_link.key}" %>
            <td style="overflow-x:auto"><%= link shortened_url, to: shortened_url, target: "_blank" %></td>
            <td><%= short_link.hit_count %></td>
          </tr>
        <% end %>
      </tbody>
    </table>

    <%= if @current_user do %>
      <span><%= live_patch "Admin", to: Routes.short_link_index_path(@socket, :index) %></span>
    <% end %>
    """
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
