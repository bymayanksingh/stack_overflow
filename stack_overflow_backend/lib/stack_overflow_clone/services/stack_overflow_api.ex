defmodule StackOverflowClone.Services.StackOverflowApi do
  @moduledoc """
  Service for interacting with the Stack Overflow API to fetch questions and answers.
  """

  require Logger
  alias HTTPoison.{Error, Response}

  @base_url "https://api.stackexchange.com/2.3"
  @site "stackoverflow"

  @doc """
  Search for questions on Stack Overflow based on a query string.
  Returns a list of questions with their answers.
  """
  def search_questions(query, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    pagesize = Keyword.get(opts, :pagesize, 10)
    sort = Keyword.get(opts, :sort, "relevance")
    order = Keyword.get(opts, :order, "desc")

    params = %{
      "order" => order,
      "sort" => sort,
      "q" => query,
      "site" => @site,
      "page" => page,
      "pagesize" => pagesize,
      "filter" => "withbody"
    }

    case make_request("/search/advanced", params) do
      {:ok, %{"items" => questions}} ->
        questions_with_answers =
          questions
          |> Enum.map(&fetch_question_answers/1)
          |> Enum.filter(& &1)

        {:ok, questions_with_answers}

      {:ok, %{"error_id" => _error_id, "error_message" => message}} ->
        Logger.error("Stack Overflow API error: #{message}")
        {:error, message}

      {:error, reason} ->
        Logger.error("Failed to fetch questions: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Fetch answers for a specific question ID.
  """
  def fetch_question_answers(question) do
    question_id = question["question_id"]

    case make_request("/questions/#{question_id}/answers", %{
           "order" => "desc",
           "sort" => "votes",
           "site" => @site,
           "filter" => "withbody"
         }) do
      {:ok, %{"items" => answers}} ->
        Map.put(question, "answers", answers)

      {:ok, %{"error_id" => _error_id, "error_message" => message}} ->
        Logger.error("Stack Overflow API error for question #{question_id}: #{message}")
        Map.put(question, "answers", [])

      {:error, reason} ->
        Logger.error("Failed to fetch answers for question #{question_id}: #{inspect(reason)}")
        Map.put(question, "answers", [])
    end
  end

  @doc """
  Get a specific question by ID with its answers.
  """
  def get_question(question_id, _opts \\ []) do
    params = %{
      "order" => "desc",
      "sort" => "votes",
      "site" => @site,
      "filter" => "withbody"
    }

    case make_request("/questions/#{question_id}", params) do
      {:ok, %{"items" => [question]}} ->
        question_with_answers = fetch_question_answers(question)
        {:ok, question_with_answers}

      {:ok, %{"items" => []}} ->
        Logger.warning("Question #{question_id} not found")
        {:error, "Question not found"}

      {:ok, %{"error_id" => _error_id, "error_message" => message}} ->
        Logger.error("Stack Overflow API error: #{message}")
        {:error, message}

      {:error, reason} ->
        Logger.error("Failed to fetch question #{question_id}: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp make_request(endpoint, params) do
    url = @base_url <> endpoint
    query_string = URI.encode_query(params)
    full_url = "#{url}?#{query_string}"

    case HTTPoison.get(full_url, [], timeout: 30_000, recv_timeout: 30_000) do
      {:ok, %Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} -> {:ok, data}
          {:error, reason} -> {:error, reason}
        end

      {:ok, %Response{status_code: status_code, body: body}} ->
        Logger.error("HTTP error #{status_code}: #{body}")
        # surface the status code for better upstream fallback decisions
        {:error, {:http_status, status_code}}

      {:error, %Error{reason: reason}} ->
        Logger.error("HTTPoison error: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
