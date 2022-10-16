defmodule TodoList do
   # import MultiDict

    def new(), do: MultiDict.new()

    def add_entry(todo_list, entry) do
        MultiDict.add(todo_list, entry.date, entry.title)
    end

    def entries(todo_list, date) do
        MultiDict.get(todo_list, date)
    end
end
