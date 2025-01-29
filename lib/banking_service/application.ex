defmodule BankingService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BankingServiceWeb.Telemetry,
      BankingService.Repo,
      {DNSCluster, query: Application.get_env(:banking_service, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BankingService.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: BankingService.Finch},
      # Start the transaction registry
      {Registry, keys: :unique, name: :transaction_registry},
      {Registry, keys: :unique, name: :account_registry},
      # Start a worker by calling: BankingService.Worker.start_link(arg)
      # {BankingService.Worker, arg},
      # Start to serve requests, typically the last entry
      BankingServiceWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BankingService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BankingServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
