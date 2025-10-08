defmodule StackOverflowClone.Services.GeminiService do
  @moduledoc """
  Service for interacting with Google Gemini API to rerank Stack Overflow answers.
  """

  require Logger

  @doc """
  Rerank a list of Stack Overflow answers using Google Gemini API.
  Returns the answers sorted by relevance and accuracy.
  """
  def rerank_answers(question, answers, opts \\ []) do
    model = Keyword.get(opts, :model, "gemini-2.0-flash")
    max_tokens = Keyword.get(opts, :max_tokens, 1000)

    prompt = build_reranking_prompt(question, answers)

    case Gemini.generate(prompt, model: model, max_tokens: max_tokens, temperature: 0.1) do
      {:ok, response} ->
        case Gemini.extract_text(response) do
          {:ok, text} ->
            case parse_reranking_response(text, answers) do
              {:ok, reranked_answers} -> {:ok, reranked_answers}
              {:error, reason} -> {:error, reason}
            end

          {:error, reason} ->
            Logger.error("Gemini API error extracting text: #{inspect(reason)}")
            {:error, reason}
        end

      {:error, reason} ->
        Logger.error("Gemini API error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Generate a summary of the best answer for a question.
  """
  def summarize_best_answer(question, answers) do
    if Enum.empty?(answers) do
      {:ok, "No answers available for this question."}
    else
      best_answer = List.first(answers)

      prompt = """
      Please provide a concise summary of the best answer to this Stack Overflow question:

      Question: #{question["title"]}
      Question Body: #{question["body"]}

      Best Answer:
      #{best_answer["body"]}

      Please summarize the key points and solution in 2-3 sentences.
      """

      case Gemini.generate(prompt, model: "gemini-2.0-flash", max_tokens: 200, temperature: 0.1) do
        {:ok, response} ->
          case Gemini.extract_text(response) do
            {:ok, summary} ->
              {:ok, summary}

            {:error, reason} ->
              Logger.error("Gemini API error extracting summary: #{inspect(reason)}")
              {:error, reason}
          end

        {:error, reason} ->
          Logger.error("Gemini API error for summary: #{inspect(reason)}")
          {:error, reason}
      end
    end
  end

  defp build_reranking_prompt(question, answers) do
    answers_text =
      answers
      |> Enum.with_index(1)
      |> Enum.map(fn {answer, index} ->
        """
        Answer #{index}:
        Score: #{answer["score"]}
        Body: #{String.slice(answer["body"], 0, 1000)}...
        """
      end)
      |> Enum.join("\n\n")

    """
    Please rank the following Stack Overflow answers by relevance and accuracy for this question:

    Question: #{question["title"]}
    Question Body: #{question["body"]}

    Answers to rank:
    #{answers_text}

    Please return ONLY a JSON array with the answer indices in order of relevance (most relevant first).
    For example: [2, 1, 3, 4, 5]

    Consider:
    - How well the answer addresses the question
    - Code quality and completeness
    - Correctness of the solution
    - Clarity of explanation
    - Upvotes/score as a secondary factor
    """
  end

  defp parse_reranking_response(response, answers) do
    json_match = Regex.run(~r/\[[\d,\s]+\]/, response)

    case json_match do
      [json_string] ->
        case Jason.decode(json_string) do
          {:ok, indices} when is_list(indices) ->
            reranked_answers =
              indices
              |> Enum.map(&(&1 - 1))
              |> Enum.map(&Enum.at(answers, &1))
              |> Enum.filter(& &1)

            {:ok, reranked_answers}

          {:error, reason} ->
            Logger.error("Failed to parse JSON from GEMINI response: #{inspect(reason)}")
            {:error, "Invalid JSON response from GEMINI"}
        end

      nil ->
        Logger.error("No JSON array found in GEMINI response: #{response}")
        {:error, "No ranking found in GEMINI response"}
    end
  rescue
    error ->
      Logger.error("Error parsing GEMINI response: #{inspect(error)}")
      {:error, "Failed to parse GEMINI response"}
  end
end
