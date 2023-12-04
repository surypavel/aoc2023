{:ok, str} = File.read("04.txt")

defmodule AOC do
  def load_numbers(input) do
    Regex.scan(~r/\d+/, input)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> MapSet.new()
  end

  def load_input(line) do
    line
    |> String.split(~r/[\|:]/)
    |> Enum.map(&AOC.load_numbers/1)
  end

  def rate(matches) do
    if matches > 0 do Integer.pow(2, matches - 1) else 0 end
  end

  def score_card([_game, winning, yours]) do
    MapSet.intersection(winning, yours)
    |> MapSet.size()
    |> AOC.rate()
  end
end

rating = str
  |> String.split("\n")
  |> Enum.map(&AOC.load_input/1)
  |> Enum.map(&AOC.score_card/1)
  |> Enum.sum()

IO.puts(rating)
