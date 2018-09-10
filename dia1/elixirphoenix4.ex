defmocule ElixirPhoenix do
	def upto(n) when n > 0, do: 1..n |> Enum.map(&elixirphoenix/1)
	
	defp elixirphoenix(n), do: _elixirpalavra(n, rem(n, 3), rem(n, 5))
	
	defp _elixirpalavra (_n, 0, 0), do: "elixirphoenix"
	defp _elixirpalavra (_n, 0, _), do: "Elixir"
	defp _elixirpalavra (_n, _, 0), do: "Phoenix"
	defp _elixirpalavra (n, _, _), do: n
end
