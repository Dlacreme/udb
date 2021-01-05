defmodule UDB.Command do
  require Logger

  @doc ~S"""
  Parse the given `json` into a command.
  """
  def parse(json) do
    {:ok, {:ping, json}}
  end

  def run(command)

  def run({:ping, json}) do
    {:ok, %{"result" => "pong"}}
  end

end
