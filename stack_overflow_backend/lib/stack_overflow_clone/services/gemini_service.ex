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

    Logger.info("🔄 GEMINI RERANKING: Starting rerank for question #{question["question_id"]} with #{length(answers)} answers")
    Logger.info("🔄 GEMINI RERANKING: Question title: #{question["title"]}")
    Logger.info("🔄 GEMINI RERANKING: Using model: #{model}, max_tokens: #{max_tokens}")

    prompt = build_reranking_prompt(question, answers)

    Logger.info("🔄 GEMINI API CALL: Making request to Gemini API...")
    case Gemini.generate(prompt, model: model, max_tokens: max_tokens, temperature: 0.1) do
      {:ok, response} ->
        Logger.info("✅ GEMINI API SUCCESS: Received response from Gemini API")
        case Gemini.extract_text(response) do
          {:ok, text} ->
            Logger.info("✅ GEMINI TEXT EXTRACTION: Successfully extracted text from response")
            case parse_reranking_response(text, answers) do
              {:ok, reranked_answers} ->
                Logger.info("✅ GEMINI RERANKING SUCCESS: Successfully reranked #{length(reranked_answers)} answers")
                {:ok, reranked_answers}
              {:error, reason} ->
                Logger.error("❌ GEMINI PARSING ERROR: Failed to parse reranking response: #{inspect(reason)}")
                {:error, reason}
            end

          {:error, reason} ->
            Logger.error("❌ GEMINI TEXT EXTRACTION ERROR: #{inspect(reason)}")
            {:error, reason}
        end

      {:error, reason} ->
        Logger.error("❌ GEMINI API ERROR: #{inspect(reason)}")
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
        body_preview = String.slice(answer["body"], 0, 2000)
        is_accepted = if answer["is_accepted"], do: "[ACCEPTED BY ASKER]", else: ""

        """
        ═══════════════════════════════════════
        Answer #{index}: #{is_accepted}
        Original Stack Overflow Score: #{answer["score"]} votes
        ═══════════════════════════════════════
        #{body_preview}
        """
      end)
      |> Enum.join("\n\n")

    """
    You are an expert technical assistant helping to rerank Stack Overflow answers based on ACTUAL RELEVANCE and ACCURACY, not just popularity.

    IMPORTANT: Your job is to CRITICALLY EVALUATE each answer and REORDER them if the most upvoted answer is NOT actually the best answer for the specific question asked. Do NOT just return the same order as the vote scores unless the votes truly reflect answer quality.

    Question Title: #{question["title"]}

    Full Question Context:
    #{String.slice(question["body"], 0, 1500)}

    Answers to Critically Evaluate and Rerank:
    #{answers_text}

    RANKING CRITERIA (in order of importance):

    1. DIRECT RELEVANCE (40%): Does the answer DIRECTLY address what the asker is asking? Does it answer the specific use case mentioned in the question?

    2. TECHNICAL ACCURACY (30%): Is the solution technically correct? Are there any bugs, security issues, or deprecated practices?

    3. COMPLETENESS (15%): Does the answer provide a complete solution with proper explanation? Does it include working code examples if needed?

    4. CLARITY & BEST PRACTICES (10%): Is the explanation clear? Does it follow current best practices and modern standards?

    5. VOTE COUNT (5%): Consider upvotes as a minor tiebreaker only.

    CRITICAL INSTRUCTIONS:
    - IGNORE vote counts as the primary ranking factor
    - PRIORITIZE answers that directly solve the asker's specific problem over generic popular answers
    - DEMOTE answers that are outdated, use deprecated methods, or don't match the question's context
    - PROMOTE answers with clear explanations and modern, secure code examples
    - If an answer is accepted by the asker, consider it heavily as they know their use case best
    - You MUST reorder answers if the analysis shows a lower-voted answer is actually more relevant

    Return ONLY a JSON array with answer indices ordered from MOST RELEVANT to LEAST RELEVANT.
    Format: [3, 1, 5, 2, 4]

    Do NOT return the same order unless the vote ranking truly matches relevance ranking.
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
