{:ok, str} = File.read("02.txt")

defmodule AOC do
  def parse_line(line) do
    line
    |> String.split(":")
    |> Enum.at(1)
    |> String.split(~r/,|;/)
    |> Enum.map(&Regex.named_captures(~r/(?<num>\d+) (?<type>[a-z]+)/, &1))
  end

  def min_cubes(game) do
    startState = %{
      "red" => 0,
      "green" => 0,
      "blue" => 0
    }

    Enum.reduce(game, startState, fn curr, acc ->
      Map.update!(acc, curr["type"], fn value ->
        Enum.max([value, String.to_integer(curr["num"])])
      end)
    end)
  end
end

result =
  str
  |> String.split("\n")
  |> Enum.map(&AOC.parse_line/1)
  |> Enum.map(&AOC.min_cubes/1)
  |> Enum.map(&Enum.product(Map.values(&1)))
  |> Enum.sum()

IO.puts(result)
