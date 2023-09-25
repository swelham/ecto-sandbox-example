defmodule ParallelSandbox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ParallelSandboxWeb.Telemetry,
      # Start the Ecto repository
      ParallelSandbox.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ParallelSandbox.PubSub},
      # Start Finch
      {Finch, name: ParallelSandbox.Finch},
      # Start the Sandbox Connection Supervisor
      {DynamicSupervisor, name: ParallelSandbox.SandboxConnSupervisor, strategy: :one_for_one},
      # Start the Endpoint (http/https)
      ParallelSandboxWeb.Endpoint
      # Start a worker by calling: ParallelSandbox.Worker.start_link(arg)
      # {ParallelSandbox.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ParallelSandbox.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ParallelSandboxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
