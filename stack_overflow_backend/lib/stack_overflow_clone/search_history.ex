defmodule StackOverflowClone.SearchHistory do
  @moduledoc """
  The SearchHistory context.
  """

  import Ecto.Query, warn: false
  alias StackOverflowClone.Repo

  alias StackOverflowClone.SearchHistory.SearchEntry

  @doc """
  Returns the list of search_entries.

  ## Examples

      iex> list_search_entries()
      [%SearchEntry{}, ...]

  """
  def list_search_entries do
    Repo.all(SearchEntry)
  end

  @doc """
  Gets a single search_entry.

  Raises `Ecto.NoResultsError` if the Search entry does not exist.

  ## Examples

      iex> get_search_entry!(123)
      %SearchEntry{}

      iex> get_search_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_search_entry!(id), do: Repo.get!(SearchEntry, id)

  @doc """
  Creates a search_entry.

  ## Examples

      iex> create_search_entry(%{field: value})
      {:ok, %SearchEntry{}}

      iex> create_search_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_search_entry(attrs) do
    %SearchEntry{}
    |> SearchEntry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a search_entry.

  ## Examples

      iex> update_search_entry(search_entry, %{field: new_value})
      {:ok, %SearchEntry{}}

      iex> update_search_entry(search_entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_search_entry(%SearchEntry{} = search_entry, attrs) do
    search_entry
    |> SearchEntry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a search_entry.

  ## Examples

      iex> delete_search_entry(search_entry)
      {:ok, %SearchEntry{}}

      iex> delete_search_entry(search_entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_search_entry(%SearchEntry{} = search_entry) do
    Repo.delete(search_entry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking search_entry changes.

  ## Examples

      iex> change_search_entry(search_entry)
      %Ecto.Changeset{data: %SearchEntry{}}

  """
  def change_search_entry(%SearchEntry{} = search_entry, attrs \\ %{}) do
    SearchEntry.changeset(search_entry, attrs)
  end

  @doc """
  Returns the list of recent search entries for a specific user.

  ## Examples

      iex> list_recent_searches_for_user(123, 5)
      [%SearchEntry{}, ...]

  """
  def list_recent_searches_for_user(user_id, limit \\ 5) do
    SearchEntry
    |> where([s], s.user_id == ^user_id)
    |> order_by([s], desc: s.searched_at)
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Gets recent search entries for a user with preloaded user information.

  ## Examples

      iex> list_recent_searches_for_user_with_user(123)
      [%SearchEntry{user: %User{}}, ...]

  """
  def list_recent_searches_for_user_with_user(user_id, limit \\ 5) do
    SearchEntry
    |> where([s], s.user_id == ^user_id)
    |> order_by([s], desc: s.searched_at)
    |> limit(^limit)
    |> preload(:user)
    |> Repo.all()
  end

  @doc """
  Returns all search entries for a specific user ordered by most recent first.
  """
  def list_all_searches_for_user(user_id) do
    SearchEntry
    |> where([s], s.user_id == ^user_id)
    |> order_by([s], desc: s.searched_at)
    |> Repo.all()
  end
end
