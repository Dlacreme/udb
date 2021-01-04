defmodule UDBServerTest do
  use ExUnit.Case
  @moduletag :capture_log

  setup do
    Application.stop(:udb)
    :ok = Application.start(:udb)
  end

  setup do
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 8080, opts)
    %{socket: socket}
  end

  test "server is alive", %{socket: socket} do
    assert send_and_recv(socket, "ping") == "pong"
  end

  defp send_and_recv(socket, command) do
    :ok = :gen_tcp.send(socket, command)
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end

end
