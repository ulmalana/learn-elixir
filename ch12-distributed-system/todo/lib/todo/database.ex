defmodule Todo.Database do
  # use GenServer
  # @pool_size 3

  @db_folder "./persist"

  def child_spec(_) do
    File.mkdir_p!(@db_folder)
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
    {_results, bad_nodes} =
      :rpc.multicall(
        __MODULE__,
        :store_local,
        [key, data],
        :timer.seconds(5)
      )

    Enum.each(bad_nodes, &IO.puts("Store failed on node #{&1}"))
    :ok
  end

  def store_local(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_id ->
        Todo.DatabaseWorker.store(worker_id, key, data)
      end
    )
  end

  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_id ->
        Todo.DatabaseWorker.get(worker_id, key)
      end)
  end

end
