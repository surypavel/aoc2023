{:ok, str} = File.read("15.txt")

defmodule AOC do
  def hash(str) do
    str |> String.to_charlist() |> Enum.reduce(0, fn (curr, acc) -> Integer.mod(((acc + curr) * 17), 256) end)
  end
end

str |> String.split(",") |> Enum.map(&AOC.hash/1) |> Enum.sum() |> IO.inspect()
