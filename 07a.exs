{:ok, str} = File.read("07.txt")

defmodule AOC do
  def load_characters(input) do
    Regex.scan(~r/[\d|T|J|Q|K|A]/, input)
    |> List.flatten()
  end

  def load_input(input) do
    [cards_string, bid_string] = input |> String.split(" ")
    {AOC.load_characters(cards_string), String.to_integer(bid_string)}
  end

  def analyse(cards) do
    { AOC.analyse_type(cards), AOC.analyse_order(cards) }
  end

  def analyse_type(chars) do
    chars
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.filter(fn x -> x > 1 end)
    |> Enum.sort(:desc)
  end

  def analyse_order(chars) do
    chars
    |> Enum.map(fn
      "T" -> "10"
      "J" -> "11"
      "Q" -> "12"
      "K" -> "13"
      "A" -> "14"
      x -> x
    end)
    |> Enum.map(&String.to_integer/1)
  end
end

str
|> String.split("\n")
|> Enum.map(&AOC.load_input/1)
|> Enum.sort_by(fn {cards, _} -> AOC.analyse(cards) end)
|> Enum.with_index(1)
|> Enum.reverse()
|> Enum.map(fn {{_, bid}, rank} -> bid * rank end)
|> Enum.sum()
|> IO.puts()
