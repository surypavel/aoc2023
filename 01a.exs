{:ok, str} = File.read("01.txt")

defmodule AOC do
  def find_number(parameter1) do
    numbers = parameter1 |> String.graphemes() |> Enum.filter(&String.match?(&1, ~r/\d/))
    (Enum.at(numbers, 0) <> Enum.at(numbers, -1)) |> Integer.parse |> elem(0)
  end
end

result =
  str
  |> String.split("\n")
  |> Enum.map(&AOC.find_number(&1))
  |> Enum.sum()

IO.puts(result)
