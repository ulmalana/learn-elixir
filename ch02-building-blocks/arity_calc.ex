defmodule Calculator1 do
    def sum(a) do
        sum(a,0)
    end

    def sum(a,b) do
        a + b
    end
end

defmodule Calculator2 do
    # \\ for default value
    def sum(a, b \\0) do
        a + b
    end
end

defmodule MyModule do
    def fun(a, b \\ 2, c, d \\ 1) do
        a + b + c + d
    end
end
