defmodule StackOverflowClone.SearchHistory.SearchEntry do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :query, :searched_at, :user_id, :inserted_at, :updated_at]}
  schema "search_entries" do
    field :query, :string
    field :searched_at, :utc_datetime

    belongs_to :user, StackOverflowClone.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(search_entry, attrs) do
    search_entry
    |> cast(attrs, [:query, :searched_at, :user_id])
    |> validate_required([:query, :searched_at])
    |> foreign_key_constraint(:user_id)
  end
end
