defmodule UDB.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: UDB.Server.SocketSupervisor},
      {UDB.Server, name: UDB.Server, strategy: :one_for_one},
    ]
    opts = [strategy: :one_for_one, name: UDB.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
