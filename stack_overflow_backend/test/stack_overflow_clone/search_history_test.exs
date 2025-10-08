defmodule StackOverflowClone.SearchHistoryTest do
  use StackOverflowClone.DataCase

  alias StackOverflowClone.SearchHistory

  describe "search_entries" do
    alias StackOverflowClone.SearchHistory.SearchEntry

    import StackOverflowClone.SearchHistoryFixtures

    @invalid_attrs %{query: nil, searched_at: nil}

    test "list_search_entries/0 returns all search_entries" do
      search_entry = search_entry_fixture()
      assert SearchHistory.list_search_entries() == [search_entry]
    end

    test "get_search_entry!/1 returns the search_entry with given id" do
      search_entry = search_entry_fixture()
      assert SearchHistory.get_search_entry!(search_entry.id) == search_entry
    end

    test "create_search_entry/1 with valid data creates a search_entry" do
      valid_attrs = %{query: "some query", searched_at: ~U[2025-10-07 02:36:00Z]}

      assert {:ok, %SearchEntry{} = search_entry} = SearchHistory.create_search_entry(valid_attrs)
      assert search_entry.query == "some query"
      assert search_entry.searched_at == ~U[2025-10-07 02:36:00Z]
    end

    test "create_search_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SearchHistory.create_search_entry(@invalid_attrs)
    end

    test "update_search_entry/2 with valid data updates the search_entry" do
      search_entry = search_entry_fixture()
      update_attrs = %{query: "some updated query", searched_at: ~U[2025-10-08 02:36:00Z]}

      assert {:ok, %SearchEntry{} = search_entry} =
               SearchHistory.update_search_entry(search_entry, update_attrs)

      assert search_entry.query == "some updated query"
      assert search_entry.searched_at == ~U[2025-10-08 02:36:00Z]
    end

    test "update_search_entry/2 with invalid data returns error changeset" do
      search_entry = search_entry_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SearchHistory.update_search_entry(search_entry, @invalid_attrs)

      assert search_entry == SearchHistory.get_search_entry!(search_entry.id)
    end

    test "delete_search_entry/1 deletes the search_entry" do
      search_entry = search_entry_fixture()
      assert {:ok, %SearchEntry{}} = SearchHistory.delete_search_entry(search_entry)
      assert_raise Ecto.NoResultsError, fn -> SearchHistory.get_search_entry!(search_entry.id) end
    end

    test "change_search_entry/1 returns a search_entry changeset" do
      search_entry = search_entry_fixture()
      assert %Ecto.Changeset{} = SearchHistory.change_search_entry(search_entry)
    end
  end
end
