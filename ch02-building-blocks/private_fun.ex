defmodule TestPrivate do
    # public function. can be called from outside
    def double(a) do
        sum(a,a)
    end

    # private function. only available in this module.
    # this sum() is used to implement double()
    defp sum(a,b) do
        a + b
    end
end
