defmodule StackOverflowClone.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Configure Gemini API key at runtime
    api_key = System.get_env("GEMINI_API_KEY")

    if api_key do
      Application.put_env(:gemini_ex, :api_key, api_key)
    end

    children = [
      StackOverflowCloneWeb.Telemetry,
      StackOverflowClone.Repo,
      {DNSCluster,
       query: Application.get_env(:stack_overflow_clone, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: StackOverflowClone.PubSub},
      # Start a worker by calling: StackOverflowClone.Worker.start_link(arg)
      # {StackOverflowClone.Worker, arg},
      # Start to serve requests, typically the last entry
      StackOverflowCloneWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StackOverflowClone.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, pid} ->
        # Initialize the cache service after the application starts
        StackOverflowClone.Services.CacheService.init_cache()
        {:ok, pid}

      error ->
        error
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StackOverflowCloneWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
