defmodule Fhub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Fhub.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Fhub.PubSub}
      # Start a worker by calling: Fhub.Worker.start_link(arg)
      # {Fhub.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Fhub.Supervisor)
  end
end
