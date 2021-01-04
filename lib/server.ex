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
    IO.puts("New client connected")
    msg =
      with  {:ok, data} <- read_line(socket),
            {:ok, command} <- parse_line(data),
            do: run(command)
    write_line(socket, msg)
    serve(socket)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp parse_line(data) do
    {:ok, data}
  end

  defp run(command) do
    IO.puts(inspect command)
    :ok
  end

  defp write_line(socket, {:ok, text}) do
    :gen_tcp.send(socket, text)
  end

  defp write_line(socket, {:error, :unknown_command}) do
    # known error. handle the scenario
    :gen_tcp.send(socket, "UNKNOWN COMMAND\r\n")
  end

  defp write_line(_socket, {:error, :close}) do
    exit(:shutdown)
  end

  defp write_line(socket, {:error, :not_found}) do
    :gen_tcp.send(socket, "NOT FOUND\r\n")
  end

  defp write_line(socket, {:error, error}) do
    :gen_tcp.send(socket, "ERROR\r\n")
    exit(error)
  end

end
