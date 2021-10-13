defmodule UrlShortnr.ShortLinks.ShortLink do
  use Ecto.Schema
  import Ecto.Changeset

  schema "short_links" do
    field :hit_count, :integer
    field :key, :string
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(short_link, attrs) do
    short_link
    |> cast(attrs, [:key, :url, :hit_count])
    |> validate_required([:key, :url, :hit_count])
  end
end
