defmodule StackOverflowClone.Repo.Migrations.CreateSearchEntries do
  use Ecto.Migration

  def change do
    create table(:search_entries) do
      add :query, :text
      add :searched_at, :utc_datetime
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:search_entries, [:user_id])
  end
end
