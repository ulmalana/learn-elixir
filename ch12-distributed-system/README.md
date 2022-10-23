# Chapter 12 - Building distributed systems

Processes located on different machines still can communicate each other using messages. We can also create a cluster of processes (which are not necessarily on the same machine.)

## Starting a cluster

We can start different nodes or shell sessions using the command below:
```shell
# on node/shell 1
$ iex --sname node1@mrmx

# on node/shell 2
$ iex --sname node2@mrmx

# on node/shell 3
$ iex --sname node3@mrmx
```

To connect all the nodes, we can run the following:
```elixir
## on node 2 ##
iex(node2@mrmx)3> Node.connect(:node1@mrmx)
true
iex(node2@mrmx)4> Node.list() # check the cluster
[:node1@mrmx]

## on node 3 ##
iex(node3@mrmx)1> Node.connect(:node2@mrmx)
true
iex(node3@mrmx)2> Node.list() # check the cluster
[:node2@mrmx, :node1@mrmx]
iex(node3@mrmx)3> Node.list([:this, :visible])
[:node3@mrmx, :node2@mrmx, :node1@mrmx]
```

Interprocess communication:
```elixir
### on node 1 ###
iex(node1@mrmx)3> Node.spawn(:node2@mrmx, fn -> IO.puts("Halo from #{node}") end)
Halo from node2@mrmx
#PID<11771.128.0>
iex(node1@mrmx)4> caller = self()
#PID<0.112.0>
iex(node1@mrmx)5> Node.spawn(:node2@mrmx, fn -> send(caller, {:response, 4+9}) end)
#PID<11771.129.0>
iex(node1@mrmx)6> flush()
{:response, 13}
:ok                                                                             
iex(node1@mrmx)7> Process.register(self(), :shell)
true
iex(node1@mrmx)8> send({:shell, :node2@mrmx}, "halo from node1")
"halo from node1"

### on node 2 ###
iex(node2@mrmx)6> flush()
"halo from node1"
:ok  
```

For communication, we can also use `:global` module which acts like a global registry or `:pg2` module which is a process group. Finally we can link and monitor processes on different machines as well.
