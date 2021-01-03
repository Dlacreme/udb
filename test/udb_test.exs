defmodule UDBTest do
  use ExUnit.Case
  doctest UDB

  test "greets the world" do
    assert UDB.hello() == :world
  end
end
