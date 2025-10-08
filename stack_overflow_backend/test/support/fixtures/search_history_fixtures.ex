defmodule StackOverflowClone.SearchHistoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `StackOverflowClone.SearchHistory` context.
  """

  @doc """
  Generate a search_entry.
  """
  def search_entry_fixture(attrs \\ %{}) do
    {:ok, user} =
      StackOverflowClone.Accounts.create_user(%{
        email: "test@example.com",
        name: "Test User"
      })

    {:ok, search_entry} =
      attrs
      |> Enum.into(%{
        query: "some query",
        searched_at: ~U[2025-10-07 02:36:00Z],
        user_id: user.id
      })
      |> StackOverflowClone.SearchHistory.create_search_entry()

    search_entry
  end
end
