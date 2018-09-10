defmodule ElixirPhoenix do
def upto(n) when n > 0 do
1..n |> Enum.map(&elixirphoenix/1)
end
defp elixirphoenix(n)
cond do
rem(n, 3) ==
"elixirphoenix"
rem(n, 3) ==
"elixir"
rem(n, 5) ==
"phoenix"
true ->
n
end
end
end
