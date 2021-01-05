defmodule UDB.Server do
  require Logger
  use GenServer

  @doc """
  Starts the server
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [
      UDB.Config.server() |> Map.fetch!(:ip) |> String.to_charlist(),
      UDB.Config.server() |> Map.fetch!(:port) |> Integer.parse() |> elem(0)
    ], opts)
  end

  def init([_ip, port]) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Waiting for connection on #{port}")
    Supervisor.start_link([{Task, fn -> loop_acceptor(socket) end}], strategy: :one_for_one)
    {:ok, socket}
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(UDB.Server.SocketSupervisor, fn -> serve(client) end, [])
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    Logger.info("New client connected")
    msg =
      with  {:ok, json} <- read_line(socket),
            {:ok, command} <- UDB.Command.parse(json),
            do: UDB.Command.run(command)
    write(socket, msg)
    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    case Jason.decode(data) do
      {:ok, json} ->
        {:ok, json}
      {:error, _} ->
        {:error, :invalid_format}
    end
  end

  defp write(socket, {:ok, data}) do
    :gen_tcp.send(socket, encode(data))
  end

  defp write(socket, {:error, :invalid_format}) do
    :gen_tcp.send(socket, "INVALID QUERY\r\n")
  end

  defp write(socket, {:error, :unknown_command}) do
    :gen_tcp.send(socket, "UNKNOWN COMMAND\r\n")
  end

  defp write(_socket, {:error, :close}) do
    exit(:shutdown)
  end

  defp write(socket, {:error, :not_found}) do
    :gen_tcp.send(socket, "NOT FOUND\r\n")
  end

  defp write(socket, {:error, error}) do
    :gen_tcp.send(socket, "ERROR\r\n")
    exit(error)
  end

  defp encode(data), do: "#{Jason.encode!(data)}\r\n"

end
