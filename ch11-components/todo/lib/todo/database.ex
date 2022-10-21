defmodule Todo.Database do
  # use GenServer
  # @pool_size 3

  @db_folder "./persist"

  #def start_link(_) do
  #  GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  #end
  # def start_link do
  #   File.mkdir_p!(@db_folder)

  #   children = Enum.map(1..@pool_size, &worker_spec/1)
  #   Supervisor.start_link(children, strategy: :one_for_one)
  # end

  # defp worker_spec(worker_id) do
  #   default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
  #   Supervisor.child_spec(default_worker_spec, id: worker_id)
  # end

  def child_spec(_) do
    File.mkdir_p!(@db_folder)
    #%{
    #  id: __MODULE__,
    #  start: {__MODULE__, :start_link, []},
    #  type: :supervisor
    #}
    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: 3
      ],
      [@db_folder])
  end

  def store(key, data) do
    # GenServer.cast(__MODULE__, {:store, key, data})
    # key
    # |> choose_worker()
    # |> Todo.DatabaseWorker.store(key, data)

    :poolboy.transaction(
      __MODULE__,
      fn worker_id ->
        Todo.DatabaseWorker.store(worker_id, key, data)
      end
    )
  end

  def get(key) do
    #GenServer.call(__MODULE__, {:get, key})
    # key
    # |> choose_worker()
    # |> Todo.DatabaseWorker.get(key)
    :poolboy.transaction(
      __MODULE__,
      fn worker_id ->
        Todo.DatabaseWorker.get(worker_id, key)
      end)
  end

  # defp choose_worker(key) do
  #   :erlang.phash2(key, @pool_size) + 1
  # end

  # def init(_) do
  #   File.mkdir_p!(@db_folder)
  #   {:ok, nil}
  # end

  # def handle_cast({:store, key, data}, state) do
  #   key
  #   |> file_name()
  #   |> File.write!(:erlang.term_to_binary(data))

  #   {:noreply, state}
  # end

  # def handle_call({:get, key}, _, state) do
  #   data = case File.read(file_name(key)) do
  #            {:ok, contents} -> :erlang.binary_to_term(contents)
  #            _ -> nil
  #          end

  #   {:reply, data, state}
  # end

  # defp file_name(key) do
  #   Path.join(@db_folder, to_string(key))
  # end
end
