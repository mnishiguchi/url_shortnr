defmodule UrlShortnrWeb.ShortLinkLive.FormComponent do
  use UrlShortnrWeb, :live_component

  alias UrlShortnr.ShortLinks

  @impl true
  def update(%{short_link: short_link} = assigns, socket) do
    changeset = ShortLinks.change_short_link(short_link)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
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

  defp save_short_link(socket, :edit, short_link_params) do
    case ShortLinks.update_short_link(socket.assigns.short_link, short_link_params) do
      {:ok, _short_link} ->
        {:noreply,
         socket
         |> put_flash(:info, "Short link updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_short_link(socket, :new, short_link_params) do
    case ShortLinks.create_short_link(short_link_params) do
      {:ok, _short_link} ->
        {:noreply,
         socket
         |> put_flash(:info, "Short link created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
