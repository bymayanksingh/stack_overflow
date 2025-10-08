defmodule StackOverflowClone.Repo do
  use Ecto.Repo,
    otp_app: :stack_overflow_clone,
    adapter: Ecto.Adapters.Postgres
end
