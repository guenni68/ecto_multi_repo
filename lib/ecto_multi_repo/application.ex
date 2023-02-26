defmodule EctoMultiRepo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias EctoMultiRepo.{
    ProcessRegistry,
    ProxySupervisor
  }

  @impl true
  def start(_type, _args) do
    children = [
      ProcessRegistry,
      ProxySupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EctoMultiRepo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
