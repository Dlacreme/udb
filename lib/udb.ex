defmodule UDB do
  require UDB.Config

  @moduledoc """
  UDB is the main entry of UDB System.
  It is nothing more than orchestrator of all the other processes.
  """

  @doc """
  Starts UDB
  """
  def start do
    UDB.Config.validate()
  end

end
