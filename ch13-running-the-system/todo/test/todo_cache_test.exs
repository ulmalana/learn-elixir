defmodule TodoCacheTest do
  use ExUnit.Case

  test "server_process" do
    # {:ok, cache} = Todo.Cache.start()
    # bob_pid = Todo.Cache.server_process(cache, "bob")
    bob_pid = Todo.Cache.server_process("bob")

    assert bob_pid != Todo.Cache.server_process("alice")
    assert bob_pid == Todo.Cache.server_process("bob")
  end

  test "todo operations" do
    # {:ok, cache} = Todo.Cache.start()
    # alice = Todo.Cache.server_process(cache, "alice")
    alice = Todo.Cache.server_process("alice")
    Todo.Server.add_entry(alice, %{date: ~D[2022-12-12], title: "Excercise"})
    entries = Todo.Server.entries(alice, ~D[2022-12-12])

    assert [%{date: ~D[2022-12-12], title: "Excercise"}] = entries
  end
end
