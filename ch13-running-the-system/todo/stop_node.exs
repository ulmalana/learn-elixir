if Node.connect(:todo_system@mrmx) == true do
  :rpc.call(:todo_system@mrmx, System, :stop, [])
  IO.puts("Node terminated.")
else
  IO.puts("cant connect to a remote node")
end
