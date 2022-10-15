defmodule Todo.Server do
  use GenServer

  def start(todo_name) do
    GenServer.start(Todo.Server, todo_name)
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  @impl GenServer
  def init(todo_name) do
    {:ok, {todo_name, Todo.Database.get(todo_name) || Todo.List.new()}}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {todo_name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(todo_name, new_list)
    {:noreply, {todo_name, new_list}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {todo_name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {todo_name, todo_list}}
  end
end
