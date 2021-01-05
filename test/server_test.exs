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
    cmd = encode(%{"command" => "ping"})
    assert send_and_recv(socket, cmd) |> get_result() == "pong"
  end

  defp send_and_recv(socket, command) do
    :ok = :gen_tcp.send(socket, command)
    case :gen_tcp.recv(socket, 0, 10000) do
      {:ok, data} ->
        data
      {:error, e} ->
        "{\"result\": \"#{inspect e}\"}"
    end
  end

  defp get_result(data) do
    Jason.decode!(data) |> Map.fetch!("result")
  end

  defp encode(data) do
    "#{Jason.encode!(data)}\r\n"
  end

end
