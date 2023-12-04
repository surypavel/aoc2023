{:ok, str} = File.read("04.txt")

defmodule AOC do
  def load_numbers(input) do
    Regex.scan(~r/\d+/, input)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
  end

  def load_input(line) do
    line
    |> String.split(~r/[\|:]/)
    |> Enum.map(&AOC.load_numbers/1)
  end

  def new_cards([game, winning, yours]) do
    game_no = Enum.at(game, 0)

    intersectionSize =
      MapSet.new(winning)
      |> MapSet.intersection(MapSet.new(yours))
      |> MapSet.size()

    {game_no,
     if intersectionSize > 0 do
       (game_no + 1)..(game_no + intersectionSize)
     else
       []
     end}
  end

  def game_round({game_no, new_cards}, acc) do
    current_copies = Map.get(acc, game_no, 0)

    new_cards
    |> Enum.reduce(acc, fn new_card, acc ->
      increment = current_copies + 1
      Map.update(acc, new_card, increment, fn count -> count + increment end)
    end)
  end
end

wins =
  str
  |> String.split("\n")
  |> Enum.map(&AOC.load_input/1)
  |> Enum.map(&AOC.new_cards/1)

number_of_copies =
  wins
  |> Enum.reduce(Map.new(), &AOC.game_round/2)
  |> Map.values()
  |> Enum.sum()

number_of_originals = length(wins)

IO.puts(number_of_copies + number_of_originals)
