# Fault Toleranc Basics

* Fault tolerance is a first-class concept in BEAM.
  * Acknowledge the existence of failures, minimize the impact and recover without intervention.

## Runtime errors
* `:error`: common runtime error such as arithmetic error, nonexistent files, raised errors, etc.
* `:exit`: used to deliberately terminate a process
* `:throw`: to allow nonlocal returns (from a deep nested recursion).

Runtime errors **can have arbitrary value** (term) that can be returned. If a runtime error isnt handled, the **corresponding process will terminate**.

## Error handling

To handle errors, we can use `try .. catch ... -> ... after ...`pattern.
```elixir
# execute this do block first
try do
...

# catch any error from do block
catch _,_  ->
IO.puts("Error caught") #example

# always execute this block regardless of the result from above blocks
after
IO.puts("cleanup code") # example
end
```

## Errors in Concurrent systems
Each process in BEAM is **isolated and independent**. A crash in one process **wont affect** the others.

```elixir
    spawn(fn ->
        spawn(fn ->
            Process.sleep(2000)
            IO.puts("Process 2 finished")
        end)

        raise("something wrong")
    end)

#PID<0.131.0> 
# 09:33:27.121 [error] Process #PID<0.131.0> raised an exception
# ** (RuntimeError) something wrong
#    (stdlib 3.17) erl_eval.erl:683: :erl_eval.do_apply/6

# Process 2 finished
```

For detecting a crashed process, we can **link** two processes. If one of them terminates, it will send an **exit signal**. For normal termination (like finished jobs), the exit reason is `:normal`. If the exit signal is not `:normal`, the linked process is **also taken down**. We can connect current process to another with `Process.link/1` or with `spawn_link/1` when creating a new process and link it to the current one. If we have a tree of linked processes, and one of them crashes, then the **entire tree will be taken down**.

```elixir
    spawn(fn ->
        spawn_link(fn ->
            Process.sleep(2000)
            IO.puts("Process 2 finished")
        end)
    raise("something wrong") # this will cause process 2 to terminate
    end)
    
#PID<0.140.0>
# 09:38:17.324 [error] Process #PID<0.140.0> raised an exception
# ** (RuntimeError) something wrong
#    (stdlib 3.17) erl_eval.erl:683: :erl_eval.do_apply/6  
```

We can also trap exits with `Process.flag(:trap_exit, true)`. With trapping exits, if one process crashed, the **linked process wont be taken down** and receive a message instead. We can detect crashed process without being affected.

```elixir
    spawn(fn -> 
        Process.flag(:trap_exit, true)
        spawn_link(fn -> raise("something went wrong with process 2") end)
    
        receive do
            msg -> IO.inspect(msg)
        end
    end)
#PID<0.149.0>
# 09:41:23.247 [error] Process #PID<0.150.0> raised an exception
# ** (RuntimeError) something went wrong with process 2
#    (stdlib 3.17) erl_eval.erl:683: :erl_eval.do_apply/6

{:EXIT, #PID<0.150.0>,                                
 {%RuntimeError{message: "something went wrong with process 2"},
  [{:erl_eval, :do_apply, 6, [file: 'erl_eval.erl', line: 683]}]}}
```

Finally, one process can monitor other processes as well using `Process.monitor(<target_pid>)`. It will create unidirectional propagation when one process crashes, instead of bidirectional. If the monitored processes terminate, the monitor will receive a message in the format `{:DOWN, monitor_ref, :process, from_pid, exit_reason}`.

```elixir
target_pid = spawn(fn ->
    Process.sleep(1000)
end)
#PID<0.154.0>

Process.monitor(target_pid)
#Reference<0.4046746253.3992715266.49247>

receive do
    msg -> IO.inspect(msg)
end
{:DOWN, #Reference<0.4046746253.3992715266.49247>, :process, #PID<0.154.0>,
 :noproc}
```
