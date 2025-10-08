defmodule StackOverflowCloneWeb.QuestionsController do
  use StackOverflowCloneWeb, :controller

  alias StackOverflowClone.Services.StackOverflowService

  action_fallback StackOverflowCloneWeb.FallbackController

  @doc """
  Search for questions on Stack Overflow.

  GET /api/questions/search?q=query&user_id=123&rerank=true
  """
  def search(conn, params) do
    query = params["q"]
    user_id = params["user_id"]
    rerank = params["rerank"] == "true"

    if is_nil(query) or query == "" do
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Query parameter 'q' is required"})
    else
      user_id = if user_id, do: String.to_integer(user_id), else: nil

      result =
        if rerank do
          StackOverflowService.search_and_rerank_questions(query, user_id)
        else
          StackOverflowService.search_questions(query, user_id)
        end

      case result do
        {:ok, questions} ->
          conn
          |> put_status(:ok)
          |> json(%{
            data: questions,
            meta: %{
              total: length(questions),
              query: query,
              reranked: rerank
            }
          })

        {:error, {:http_status, status}} when status in [400, 401, 403, 404, 409, 429] ->
          # Gracefully degrade on client/rate-limit errors from Stack Overflow API
          conn
          |> put_status(:ok)
          |> json(%{
            data: [],
            meta: %{
              total: 0,
              query: query,
              reranked: rerank,
              note: "Upstream API limited or errored (status #{status}); showing no results."
            }
          })

        {:error, reason} ->
          conn
          |> put_status(:internal_server_error)
          |> json(%{error: "Failed to search questions: #{inspect(reason)}"})
      end
    end
  end

  @doc """
  Get a specific question by ID with optional AI reranking.

  GET /api/questions/:id?rerank=true
  """
  def show(conn, %{"id" => question_id} = params) do
    rerank = Map.get(params, "rerank", "false") == "true"

    case StackOverflowService.get_question(question_id, rerank) do
      {:ok, question} ->
        conn
        |> put_status(:ok)
        |> json(%{data: question})

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Question not found: #{inspect(reason)}"})
    end
  end

  @doc """
  Get recent search history for a user.

  GET /api/questions/recent-searches?user_id=123
  """
  def recent_searches(conn, params) do
    user_id = params["user_id"]

    if is_nil(user_id) do
      conn
      |> put_status(:bad_request)
      |> json(%{error: "User ID parameter is required"})
    else
      user_id = String.to_integer(user_id)

      cache_searches = StackOverflowService.get_recent_searches(user_id)
      db_searches = StackOverflowService.get_recent_searches_from_db(user_id)

      conn
      |> put_status(:ok)
      |> json(%{
        data: %{
          cache: cache_searches,
          database: db_searches
        }
      })
    end
  end
end
