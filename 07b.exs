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

  def add_jokers([], jokers) do
    if jokers === 5 do [5] else [1 + jokers] end
  end

  def add_jokers([h | t], jokers) do
    [h + jokers | t]
  end

  def analyse_type(chars) do
    { jokers, frequencies } = chars
    |> Enum.frequencies()
    |> Map.pop("J", 0)

    cards = frequencies
    |> Map.values()
    |> Enum.filter(fn x -> x > 1 end)
    |> Enum.sort(:desc)

    if jokers > 0 do AOC.add_jokers(cards, jokers) else cards end
  end

  def analyse_order(chars) do
    chars
    |> Enum.map(fn
      "T" -> "10"
      "J" -> "1"
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
