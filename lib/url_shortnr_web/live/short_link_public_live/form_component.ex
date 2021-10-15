defmodule UrlShortnrWeb.ShortLinkPublicLive.FormComponent do
  use UrlShortnrWeb, :live_component

  alias UrlShortnr.ShortLinks
  alias UrlShortnr.ShortLinks.ShortLink

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> clear_changeset()

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        let={f}
        for={@changeset}
        id="short_link-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save">

        <%= text_input f, :url, phx_debounce: "300", placeholder: "Shorten your link" %>
        <%= error_tag f, :url %>

        <div>
          <%= submit "Shorten", phx_disable_with: "Processing..." %>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"short_link" => short_link_params}, socket) do
    changeset =
      socket.assigns.short_link
      |> ShortLinks.change_short_link(short_link_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"short_link" => short_link_params}, socket) do
    save_short_link(socket, socket.assigns.action, short_link_params)
  end

  defp save_short_link(socket, _new, short_link_params) do
    case ShortLinks.create_short_link(short_link_params) do
      {:ok, _short_link} ->
        socket =
          socket
          |> put_flash(:info, "Short link created successfully")
          |> clear_changeset()

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp clear_changeset(socket) do
    socket
    |> assign(short_link: %ShortLink{})
    |> assign(changeset: ShortLinks.change_short_link(%ShortLink{}))
  end
end
