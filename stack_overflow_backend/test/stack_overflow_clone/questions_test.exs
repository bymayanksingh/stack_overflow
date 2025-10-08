defmodule StackOverflowClone.QuestionsTest do
  use StackOverflowClone.DataCase

  alias StackOverflowClone.Questions

  describe "questions" do
    alias StackOverflowClone.Questions.Question

    import StackOverflowClone.QuestionsFixtures

    @invalid_attrs %{title: nil, body: nil}

    test "list_questions/0 returns all questions" do
      question = question_fixture()
      assert Questions.list_questions() == [question]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert Questions.get_question!(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      # Create a user first
      {:ok, user} =
        StackOverflowClone.Accounts.create_user(%{
          email: "test@example.com",
          name: "Test User"
        })

      valid_attrs = %{title: "some title", body: "some body", user_id: user.id}

      assert {:ok, %Question{} = question} = Questions.create_question(valid_attrs)
      assert question.title == "some title"
      assert question.body == "some body"
      assert question.user_id == user.id
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Questions.create_question(@invalid_attrs)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()
      update_attrs = %{title: "some updated title", body: "some updated body"}

      assert {:ok, %Question{} = question} = Questions.update_question(question, update_attrs)
      assert question.title == "some updated title"
      assert question.body == "some updated body"
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = Questions.update_question(question, @invalid_attrs)
      assert question == Questions.get_question!(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      assert {:ok, %Question{}} = Questions.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> Questions.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = Questions.change_question(question)
    end
  end
end
