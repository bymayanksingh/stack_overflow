defmodule StackOverflowClone.Questions.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :title, :string
    field :body, :string

    belongs_to :user, StackOverflowClone.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:title, :body, :user_id])
    |> validate_required([:title, :body, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
