defmodule KeyValTest do
  use ExUnit.Case
  doctest KeyVal

  test "greets the world" do
    assert KeyVal.hello() == :world
  end
end
