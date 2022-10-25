defmodule MyAgent do
  use GenServer

  def start_link(init_fun) do
    GenServer.start_link(__MODULE__, init_fun)
  end

  def init(init_fun) do
    {:ok, init_fun.()}
  end

  def get(pid, fun) do
    GenServer.call(pid, {:get, fun})
  end

  def update(pid, fun) do
    GenServer.call(pid, {:update, fun})
  end

  def handle_call({:get, fun}, _from, state) do
    response = fun.(state)
    {:reply, response, state}
  end

  def handle_call({:update, fun}, _from, state) do
    new_state = fun.(state)
    {:reply, :ok, new_state}
  end
end
