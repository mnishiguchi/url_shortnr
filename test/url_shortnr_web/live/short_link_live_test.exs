defmodule UrlShortnrWeb.ShortLinkLiveTest do
  use UrlShortnrWeb.ConnCase

  import Phoenix.LiveViewTest
  import UrlShortnr.ShortLinksFixtures

  @create_attrs %{hit_count: 42, key: "some key", url: "some url"}
  @update_attrs %{hit_count: 43, key: "some updated key", url: "some updated url"}
  @invalid_attrs %{hit_count: nil, key: nil, url: nil}

  defp create_short_link(_) do
    short_link = short_link_fixture()
    %{short_link: short_link}
  end

  describe "Index" do
    setup [:create_short_link]

    test "lists all short_links", %{conn: conn, short_link: short_link} do
      {:ok, _index_live, html} = live(conn, Routes.short_link_index_path(conn, :index))

      assert html =~ "Listing Short links"
      assert html =~ short_link.key
    end

    test "saves new short_link", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.short_link_index_path(conn, :index))

      assert index_live |> element("a", "New Short link") |> render_click() =~
               "New Short link"

      assert_patch(index_live, Routes.short_link_index_path(conn, :new))

      assert index_live
             |> form("#short_link-form", short_link: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#short_link-form", short_link: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.short_link_index_path(conn, :index))

      assert html =~ "Short link created successfully"
      assert html =~ "some key"
    end

    test "updates short_link in listing", %{conn: conn, short_link: short_link} do
      {:ok, index_live, _html} = live(conn, Routes.short_link_index_path(conn, :index))

      assert index_live |> element("#short_link-#{short_link.id} a", "Edit") |> render_click() =~
               "Edit Short link"

      assert_patch(index_live, Routes.short_link_index_path(conn, :edit, short_link))

      assert index_live
             |> form("#short_link-form", short_link: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#short_link-form", short_link: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.short_link_index_path(conn, :index))

      assert html =~ "Short link updated successfully"
      assert html =~ "some updated key"
    end

    test "deletes short_link in listing", %{conn: conn, short_link: short_link} do
      {:ok, index_live, _html} = live(conn, Routes.short_link_index_path(conn, :index))

      assert index_live |> element("#short_link-#{short_link.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#short_link-#{short_link.id}")
    end
  end

  describe "Show" do
    setup [:create_short_link]

    test "displays short_link", %{conn: conn, short_link: short_link} do
      {:ok, _show_live, html} = live(conn, Routes.short_link_show_path(conn, :show, short_link))

      assert html =~ "Show Short link"
      assert html =~ short_link.key
    end

    test "updates short_link within modal", %{conn: conn, short_link: short_link} do
      {:ok, show_live, _html} = live(conn, Routes.short_link_show_path(conn, :show, short_link))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Short link"

      assert_patch(show_live, Routes.short_link_show_path(conn, :edit, short_link))

      assert show_live
             |> form("#short_link-form", short_link: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#short_link-form", short_link: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.short_link_show_path(conn, :show, short_link))

      assert html =~ "Short link updated successfully"
      assert html =~ "some updated key"
    end
  end
end
