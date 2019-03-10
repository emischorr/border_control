defmodule BorderControl.Application do
  require Logger
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  alias :mnesia, as: Mnesia

  use Application

  def start(_type, _args) do
    # Setup Mnesia database
    Mnesia.create_schema([node()])
    Mnesia.start()
    Mnesia.create_table(Calls, [attributes: [:id, :call, :timestamp, :not_before]])
    Mnesia.add_table_index(Calls, :not_before)
    Mnesia.wait_for_tables([Calls], 5000)
    Logger.info "Mnesia is set up. Starting on port 2222 ..."

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: BorderControl.Worker.start_link(arg)
      # {BorderControl.Worker, arg},
      Plug.Adapters.Cowboy.child_spec(:http, BorderControl.Endpoint, [], [port: 2222]),
      {BorderControl.Forwarder, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BorderControl.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
