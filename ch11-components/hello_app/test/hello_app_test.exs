defmodule HelloAppTest do
  use ExUnit.Case
  doctest HelloApp

  test "greets the world" do
    assert HelloApp.hello() == :world
  end
end
