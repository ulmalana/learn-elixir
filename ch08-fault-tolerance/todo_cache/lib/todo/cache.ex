defmodule Todo.Cache do
  use GenServer

  def init(_) do
    Todo.Database.start_link()
    {:ok, %{}}
  end

  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} -> {:reply, todo_server, todo_servers}
      :error ->
        {:ok, new_server} = Todo.Server.start_link(todo_list_name)
        {:reply, new_server, Map.put(todo_servers, todo_list_name, new_server)}
    end
  end

  # def start do
  #   GenServer.start(__MODULE__, nil)
  # end

  def server_process(todo_list_name) do
    GenServer.call(__MODULE__, {:server_process, todo_list_name})
  end

  def start_link(_) do
    IO.puts("starting to-do cache...")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end
end
