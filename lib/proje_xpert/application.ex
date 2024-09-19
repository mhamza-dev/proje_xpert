defmodule ProjeXpert.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ProjeXpertWeb.Telemetry,
      ProjeXpert.Repo,
      {DNSCluster, query: Application.get_env(:proje_xpert, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ProjeXpert.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ProjeXpert.Finch},
      # Start a worker by calling: ProjeXpert.Worker.start_link(arg)
      # {ProjeXpert.Worker, arg},
      # Start to serve requests, typically the last entry
      ProjeXpertWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ProjeXpert.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ProjeXpertWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
