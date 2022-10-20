# Chapter 10 - Beyond GenServer

There are two more OTP-compliant workers: **Task** and **Agent**.
* `Task`: can be used for **one-off jobs**.
* `Agent`: can be used to **manage and provide concurrent access to state**.

## Tasks
* **Awaited task**: executes some function, **sends the result back** to the starter process, then dies. `Task.async/1` for starting task, `Task.await/1` to get the result. It is **linked**, if one task crashes, the starter will die too (all-or-nothing).

```elixir
iex(1)> long_job = fn ->
...(1)> Process.sleep(2000)
...(1)> :some_result
...(1)> end
#Function<45.65746770/0 in :erl_eval.expr/5>

iex(2)> task = Task.async(long_job)
%Task{
  owner: #PID<0.106.0>,
  pid: #PID<0.112.0>,
  ref: #Reference<0.2548638419.3051094018.17903>
}

iex(3)> Task.await(task)
:some_result
```

* **Non-awaited task**: executes some function **without sending any result back** to the starter process. For example, start a web server and let it handle requests without giving back any result. Usually, we dont want to link the task to the starter, so we will use `Task.start_link/1` which is OTP-compliant, instead of `spawn_link`.

```elixir
iex(9)> Task.start_link(fn ->
...(9)> Process.sleep(2000)
...(9)> IO.puts("hello from task")
...(9)> end)
{:ok, #PID<0.139.0>}
hello from task # after 2 seconds
```

More example: use non-awaited task for gathering some system metrics:
```elixir
iex(10) Todo.System.start_link()
# starting database worker 1
# starting database worker 2
# starting database worker 3
# starting to-do cache...
{:ok, #PID<0.221.0>}
[memory_usage: 29138360, process_count: 74] # after 10s
[memory_usage: 29168648, process_count: 74] # after 20s
```

## Agents
Agent is similar to `GenServer` but with less support. If `GenServer`-powered module only implements `init/1`, `handle_cast/2`, and `handle_call/3`, it **can be replaced with Agent**. If we need to use `handle_info/2` or `terminate/1`, then Agent is not enough.

```elixir
# start an agent
iex(1)> {:ok, pid} = Agent.start_link(fn -> %{name: "Bob", age: 30} end)
{:ok, #PID<0.108.0>}

# get agent's state
iex(2)> Agent.get(pid, fn state -> state.name end)
"Bob"

# update agent's state
iex(3)> Agent.update(pid, fn state -> %{state | age: state.age + 1} end)
:ok

# check the update
iex(4)> Agent.get(pid, fn state -> state end)
%{age: 31, name: "Bob"}
```

Another example: subsequent access will see the new state.

```elixir
# start a counter
iex(7)> {:ok, counter} = Agent.start_link(fn -> 0 end)
{:ok, #PID<0.114.0>}

# start a process to update the counter
iex(7)> spawn(fn -> Agent.update(counter, fn count -> count + 5 end) end)
#PID<0.116.0>

# check the result
iex(8)> Agent.get(counter, fn count -> count end)
5

# start a process again to update
iex(9)> spawn(fn -> Agent.update(counter, fn count -> count + 3 end) end)
#PID<0.119.0>

# check the result
iex(10)> Agent.get(counter, fn count -> count end)                        
8
```

Because Agent is a limited version of GenServer, then there are many things that Agent cannot do. Prefer GenServer than Agent. Example: for implementing process expiry, it can only be done using GenServer.

```elixir
iex(1)> Todo.System.start_link()
starting database worker 1
starting database worker 2
starting database worker 3
starting to-do cache...
{:ok, #PID<0.169.0>}

# start a server
iex(2)> pid = Todo.Cache.server_process("bobs_list")
Starting todo server for bobs_list
#PID<0.179.0>

# after idle for 10s, the server will terminate
Stopping todo server for bobs_list

# check the status
iex(3)> Process.alive?(pid)
false
```

## ETS Tables

Erlang Term Storage (ETS) tables can be used to share some states between multiple processes in more efficient way. It is similar to `GenServer` and `Agent` with **better performance** but **handles limited scenarios**.

The following are the benchmarking results for KeyVal server using GenServer:

```shell
$ mix run -e "Bench.run(KeyVal)"

487528 operations/sec

$ mix run -e "Bench.run(KeyVal, concurrency: 1000)"

421062 operations/sec

# with 1000 concurrent client process, the performance gets worse because the keyval server becomes the bottleneck.
```

ETS can be used to solve that bottleneck issue. It is basically a data structure (a set by default) that we can use to share system-wide state. Examples of how to create ETS table:

```elixir
iex(1)> table = :ets.new(:my_table, [])
#Reference<0.1678940777.2472935427.231065>

iex(2)> :ets.insert(table, {:key_1, 1})
true

iex(3)> :ets.insert(table, {:key_2, 2})
true

iex(4)> :ets.insert(table, {:key_1, 3})
true

iex(5)> :ets.lookup(table, :key_1)
[key_1: 3]

iex(6)> :ets.lookup(table, :key_2)
[key_2: 2]

iex(7)> :ets.lookup(table, :key_4)
[]
``` 
When we change the KeyVal implementation from GenServer to ETS table and perform the same benchmarking, we will see an improvement.

```shell
$ mix run -e "Bench.run(KeyVal)"
2805759 operations/sec

$ mix run -e "Bench.run(KeyVal, concurrency: 1000, num_updates: 100)"

8236227 operations/sec
```
