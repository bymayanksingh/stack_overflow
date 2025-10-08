defmodule StackOverflowClone.QuestionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `StackOverflowClone.Questions` context.
  """

  @doc """
  Generate a question.
  """
  def question_fixture(attrs \\ %{}) do
    {:ok, user} =
      StackOverflowClone.Accounts.create_user(%{
        email: "test@example.com",
        name: "Test User"
      })

    {:ok, question} =
      attrs
      |> Enum.into(%{
        body: "some body",
        title: "some title",
        user_id: user.id
      })
      |> StackOverflowClone.Questions.create_question()

    question
  end
end
