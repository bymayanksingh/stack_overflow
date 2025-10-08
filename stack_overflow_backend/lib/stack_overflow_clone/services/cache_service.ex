defmodule StackOverflowClone.Services.CacheService do
  @moduledoc """
  Service for caching recent search history using Erlang Term Storage
  """

  require Logger

  @table_name :search_history_cache
  @question_table_name :question_cache
  @search_results_table_name :search_results_cache
  @max_entries_per_user 5

  @doc """
  Initialize the erlang term storage table for caching search history.
  """
  def init_cache do
    # Ensure search history table exists
    case :ets.info(@table_name) do
      :undefined ->
        :ets.new(@table_name, [:named_table, :public, :set])
        Logger.info("Initialized ETS cache table: #{@table_name}")
      _ ->
        Logger.info("ETS cache table already exists: #{@table_name}")
    end

    # Ensure question cache table exists
    case :ets.info(@question_table_name) do
      :undefined ->
        :ets.new(@question_table_name, [:named_table, :public, :set])
        Logger.info("Initialized ETS cache table: #{@question_table_name}")
      _ ->
        Logger.info("ETS cache table already exists: #{@question_table_name}")
    end

    # Ensure search results cache table exists (per-query cache)
    case :ets.info(@search_results_table_name) do
      :undefined ->
        :ets.new(@search_results_table_name, [:named_table, :public, :set])
        Logger.info("Initialized ETS cache table: #{@search_results_table_name}")
      _ ->
        Logger.info("ETS cache table already exists: #{@search_results_table_name}")
    end

    :ok
  end

  @doc """
  Add a search query to the cache for a specific user.
  Get existing searches for this user
  Add new search to the beginning
  Keep only the most recent @max_entries_per_user searches
  Store in ETS
  """
  def add_search_query(user_id, query) do
    timestamp = DateTime.utc_now()

    search_entry = %{
      query: query,
      timestamp: timestamp,
      user_id: user_id
    }

    existing_searches = get_user_searches(user_id)
    updated_searches = [search_entry | existing_searches]
    trimmed_searches = Enum.take(updated_searches, @max_entries_per_user)

    :ets.insert(@table_name, {user_id, trimmed_searches})

    Logger.debug("Added search query for user #{user_id}: #{query}")
    :ok
  end

  @doc """
  Get recent search history for a user.
  """
  def get_user_searches(user_id) do
    case :ets.lookup(@table_name, user_id) do
      [{^user_id, searches}] -> searches
      [] -> []
    end
  end

  @doc """
  Get all cached searches (for debugging/admin purposes).
  """
  def get_all_searches do
    :ets.tab2list(@table_name)
  end

  @doc """
  Clear search history for a specific user.
  """
  def clear_user_searches(user_id) do
    :ets.delete(@table_name, user_id)
    Logger.debug("Cleared search history for user #{user_id}")
    :ok
  end

  @doc """
  Clear all cached searches.
  """
  def clear_all_searches do
    :ets.delete_all_objects(@table_name)
    Logger.info("Cleared all cached searches")
    :ok
  end

  @doc """
  Store a list of questions with answers in the question cache, keyed by question_id.
  """
  def put_questions(questions_with_answers) when is_list(questions_with_answers) do
    # Ensure table exists in case init_cache hasn't run yet
    case :ets.info(@question_table_name) do
      :undefined -> :ets.new(@question_table_name, [:named_table, :public, :set])
      _ -> :ok
    end

    Enum.each(questions_with_answers, fn question ->
      case Map.get(question, "question_id") do
        nil -> :ok
        qid -> :ets.insert(@question_table_name, {qid, %{data: question, cached_at: DateTime.utc_now()}})
      end
    end)

    :ok
  end

  @doc """
  Get a cached question by id if available.
  """
  def get_question(question_id) do
    # Avoid crashes if table doesn't exist
    case :ets.info(@question_table_name) do
      :undefined -> nil
      _ -> :ok
    end

    case :ets.lookup(@question_table_name, question_id) do
      [{^question_id, %{data: question}}] -> question
      [] -> nil
    end
  end

  defp normalize_query(query) when is_binary(query) do
    query
    |> String.trim()
    |> String.downcase()
  end

  @doc """
  Cache full search results for a normalized query string.
  """
  def put_search_results(query, questions_with_answers) when is_binary(query) do
    case :ets.info(@search_results_table_name) do
      :undefined -> :ets.new(@search_results_table_name, [:named_table, :public, :set])
      _ -> :ok
    end

    norm = normalize_query(query)
    :ets.insert(@search_results_table_name, {norm, %{data: questions_with_answers, cached_at: DateTime.utc_now()}})
    :ok
  end

  @doc """
  Retrieve cached search results for a query if present.
  """
  def get_search_results(query) when is_binary(query) do
    case :ets.info(@search_results_table_name) do
      :undefined -> nil
      _ ->
        norm = normalize_query(query)
        case :ets.lookup(@search_results_table_name, norm) do
          [{^norm, %{data: results}}] -> results
          [] -> nil
        end
    end
  end

  @doc """
  Check if the cache is initialized.
  """
  def cache_initialized? do
    case :ets.info(@table_name) do
      :undefined -> false
      _ -> true
    end
  end
end
