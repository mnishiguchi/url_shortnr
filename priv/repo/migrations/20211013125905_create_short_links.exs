defmodule UrlShortnr.Repo.Migrations.CreateShortLinks do
  use Ecto.Migration

  def change do
    create table(:short_links) do
      add :key, :string, null: false
      add :url, :text, null: false
      add :hit_count, :integer, default: 0

      timestamps()
    end

    # https://hexdocs.pm/ecto_sql/Ecto.Migration.html#index
    create index(:short_links, [:key], unique: true)
  end
end
