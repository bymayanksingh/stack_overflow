defmodule StackOverflowCloneWeb.UsersController do
  use StackOverflowCloneWeb, :controller

  alias StackOverflowClone.Accounts
  alias StackOverflowClone.Repo
  alias StackOverflowClone.SearchHistory.SearchEntry
  import Ecto.Query, only: [from: 2]

  action_fallback StackOverflowCloneWeb.FallbackController

  @doc """
  List all users.

  GET /api/users
  """
  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  @doc """
  Create a new user.

  POST /api/users
  Body: {"email": "user@example.com", "name": "John Doe"}
  """
  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render(:show, user: user)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: translate_errors(changeset)})
    end
  end

  @doc """
  Get a specific user by ID.

  GET /api/users/:id
  """
  def show(conn, %{"id" => id}) do
    case Accounts.get_user(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      user ->
        render(conn, :show, user: user)
    end
  end

  @doc """
  Update a user.

  PUT /api/users/:id
  Body: {"user": {"name": "Updated Name"}}
  """
  def update(conn, %{"id" => id, "user" => user_params}) do
    case Accounts.get_user(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      user ->
        case Accounts.update_user(user, user_params) do
          {:ok, user} ->
            render(conn, :show, user: user)

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: translate_errors(changeset)})
        end
    end
  end

  @doc """
  Delete a user.

  DELETE /api/users/:id
  """
  def delete(conn, %{"id" => id}) do
    case Accounts.get_user(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})

      user ->
        # Remove dependent search history to avoid FK constraint errors
        from(s in SearchEntry, where: s.user_id == ^user.id)
        |> Repo.delete_all()

        case Accounts.delete_user(user) do
          {:ok, _user} ->
            conn
            |> put_status(:no_content)
            |> json(%{})

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: translate_errors(changeset)})
        end
    end
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
