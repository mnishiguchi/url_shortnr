defmodule UrlShortnrWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias UrlShortnr.Accounts

  @doc """
  Renders a component inside the `UrlShortnrWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal UrlShortnrWeb.ShortLinkLive.FormComponent,
        id: @short_link.id || :new,
        action: @live_action,
        short_link: @short_link,
        return_to: Routes.short_link_index_path(@socket, :index) %>
  """
  def live_modal(component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(UrlShortnrWeb.ModalComponent, modal_opts)
  end

  def assign_current_user(socket, session) do
    case session["user_token"] do
      nil ->
        assign(socket, current_user: nil)

      user_token ->
        assign_new(
          socket,
          :current_user,
          fn -> Accounts.get_user_by_session_token(user_token) end
        )
    end
  end
end
