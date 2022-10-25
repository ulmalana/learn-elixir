# Chapter 13 - Running the system

## Running a system

Basic steps to run a system
1. Compile all modules.
2. Start BEAM instance and set up load paths to include all modules.
3. Start all required OTP applications.

We can run the system using `mix` and `elixir` command:

```shell
$ mix run --no-halt

# or

$ elixir -S mix run --no-halt

# or, to interact with the system later, we can give it a name
$ elixir --sname todo_system@localhost -S mix run --no-halt

# we can open a new shell session to interact with the application
$ iex --sname debugger --remsh todo_system@localhost --hidden

# from the remote shell, we can stop the system
iex(todo_system@localhost)1> System.stop()
:ok
iex(todo_system@localhost)2> *** ERROR: Shell process terminated! (^G to start new job) ***

# or we can run a script for stopping the system
$ elixir --sname terminator stop_node.exs
```

## OTP Releases

An OTP release is **a standalone**, compiled, runnable system that **consists of minimum set of OTP application** needed. We can copy OTP release to other machine and run it there without Erlang/Elixir installed.
