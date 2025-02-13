defmodule Otel.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :opentelemetry_cowboy.setup()
    OpentelemetryPhoenix.setup(adapter: :cowboy2)
    OpentelemetryEcto.setup([:otel, :repo])

    children = [
      OtelWeb.Telemetry,
      Otel.Repo,
      {DNSCluster, query: Application.get_env(:otel, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Otel.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Otel.Finch},
      # Start a worker by calling: Otel.Worker.start_link(arg)
      # {Otel.Worker, arg},
      # Start to serve requests, typically the last entry
      OtelWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Otel.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OtelWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
