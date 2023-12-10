{:ok, str} = File.read("10_clean.txt")

defmodule AOC do
  def load_map(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, x} -> {{x, y}, char} end)
    end)
  end

  def determine_position(flip_op) do
    case flip_op do
      {false, false, "."} -> false
      {true, true, "."} -> true
      {true, true, "F"} -> false
      {false, false, "F"} -> true
      {true, true, "J"} -> true
      {false, false, "J"} -> false
      {true, false, "7"} -> false
      {false, true, "7"} -> true
      {false, true, "-"} -> false
      {true, false, "-"} -> true
      {false, true, "L"} -> false
      {true, false, "L"} -> true
      {false, true, "|"} -> true
      {true, false, "|"} -> false
    end
  end

  def flood(map, index, flips) do
    0..index
    |> Enum.map(fn i -> {i, index - i} end)
    |> Enum.map(fn point ->
      {x, y} = point
      flip_x = Map.get(flips, {x - 1, y}, false)
      flip_y = Map.get(flips, {x, y - 1}, false)
      op = Map.get(map, point, ".")
      new_flip = AOC.determine_position({flip_x, flip_y, op})
      {point, new_flip}
    end)
    |> Map.new()
    |> Map.merge(flips)
  end
end

map_list = str |> AOC.load_map()
map = map_list |> Map.new()
dots = map_list |> Enum.filter(fn {_, v} -> v == "." end) |> Enum.map(fn {k, _} -> k end)
{size_x, size_y} = map |> Map.keys() |> Enum.max()

result = Enum.reduce(0..(size_x + size_y + 1), Map.new(), &AOC.flood(map, &1, &2))

dots
|> Enum.filter(fn dot -> Map.get(result, dot) == true end)
|> length()
|> IO.puts()
