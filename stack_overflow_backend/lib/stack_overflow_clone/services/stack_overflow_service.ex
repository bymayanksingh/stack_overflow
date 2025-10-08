defmodule StackOverflowClone.Services.StackOverflowService do
  @moduledoc """
  Main service that orchestrates Stack Overflow API calls, Gemini reranking, and caching.
  """

  require Logger
  alias StackOverflowClone.Services.{StackOverflowApi, GeminiService, CacheService}
  alias StackOverflowClone.{Accounts, SearchHistory}

  @doc """
  Search for questions and answers, with optional reranking and caching.
  """
  def search_questions(query, user_id \\ nil, opts \\ []) do
    with {:ok, questions_with_answers} <- StackOverflowApi.search_questions(query, opts),
         :ok <- maybe_cache_search(user_id, query),
         :ok <- maybe_save_search_history(user_id, query) do
      questions_with_answers =
        Enum.filter(questions_with_answers, fn question ->
          length(question["answers"] || []) > 0
        end)

      # Cache full questions for detail view fallback
      CacheService.put_questions(questions_with_answers)
      # Cache full search results for the query
      CacheService.put_search_results(query, questions_with_answers)

      {:ok, questions_with_answers}
    else
      {:error, {:http_status, status}} ->
        # Fallback to cached search results on client errors/rate limits
        case CacheService.get_search_results(query) do
          nil -> {:error, {:http_status, status}}
          results -> {:ok, results}
        end

      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Search for questions and rerank answers using GEMINI.
  """
  def search_and_rerank_questions(query, user_id \\ nil, opts \\ []) do
    with {:ok, questions_with_answers} <- search_questions(query, user_id, opts) do
      reranked_questions =
        questions_with_answers
        |> Enum.map(&rerank_question_answers/1)
        |> Enum.filter(& &1)

      {:ok, reranked_questions}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Get a specific question by ID with its answers, optionally reranked by AI.
  """
  def get_question(question_id, rerank \\ false) do
    # Ensure we treat id as integer for cache keys
    question_id =
      case question_id do
        id when is_integer(id) -> id
        id when is_binary(id) -> String.to_integer(id)
      end

    case StackOverflowApi.get_question(question_id, []) do
      {:ok, question} ->
        # keep cache updated on successful fetch
        CacheService.put_questions([question])

        # Apply AI reranking if requested
        final_question =
          if rerank do
            rerank_question_answers(question)
          else
            question
          end

        {:ok, final_question}

      {:error, _reason} ->
        # fallback to cache on errors (e.g., 429 or 400)
        case CacheService.get_question(question_id) do
          nil -> {:error, "Question not available"}
          question ->
            # Apply AI reranking if requested
            final_question =
              if rerank do
                rerank_question_answers(question)
              else
                question
              end

            {:ok, final_question}
        end
    end
  end

  @doc """
  Get recent search history for a user from cache.
  """
  def get_recent_searches(user_id) do
    CacheService.get_user_searches(user_id)
  end

  @doc """
  Get recent search history for a user from database.
  """
  def get_recent_searches_from_db(user_id) do
    SearchHistory.list_all_searches_for_user(user_id)
  end

  @doc """
  Initialize the cache service.
  """
  def init_cache do
    CacheService.init_cache()
  end

  defp rerank_question_answers(question) do
    answers = question["answers"] || []

    if length(answers) > 1 do
      case GeminiService.rerank_answers(question, answers) do
        {:ok, reranked_answers} ->
          Map.put(question, "reranked_answers", reranked_answers)

        {:error, reason} ->
          Logger.warning(
            "Failed to rerank answers for question #{question["question_id"]}: #{inspect(reason)}"
          )

          question
      end
    else
      question
    end
  end

  defp maybe_cache_search(nil, _query), do: :ok

  defp maybe_cache_search(user_id, query) do
    CacheService.add_search_query(user_id, query)
  end

  defp maybe_save_search_history(nil, _query), do: :ok

  defp maybe_save_search_history(user_id, query) do
    case Accounts.get_user(user_id) do
      nil ->
        Logger.warning("User #{user_id} not found, skipping search history save")
        :ok

      _user ->
        attrs = %{
          query: query,
          user_id: user_id,
          searched_at: DateTime.utc_now()
        }

        case SearchHistory.create_search_entry(attrs) do
          {:ok, _search_entry} ->
            :ok

          {:error, changeset} ->
            Logger.error("Failed to save search history: #{inspect(changeset.errors)}")
            :ok
        end
    end
  end
end
