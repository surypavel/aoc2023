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

  def determine_position(flip_left, flip_op) do
    case flip_op do
      "." -> flip_left
      "F" -> !flip_left
      "J" -> flip_left
      "7" -> !flip_left
      "-" -> flip_left
      "L" -> flip_left
      "|" -> !flip_left
    end
  end

  def calc_point(map, point, flips) do
    { x, y } = point
    flip_x = Map.get(flips, {x - 1, y}, false)
    op = Map.get(map, point, ".")
    new_flip = AOC.determine_position(flip_x, op)
    Map.put(flips, point, new_flip)
  end
end

map_list = str |> AOC.load_map()
map = map_list |> Map.new()
map_keys = map |> Map.keys() |> Enum.sort_by(fn { x, y} -> { y, x} end)
dots = map_list |> Enum.filter(fn {_, v} -> v == "." end) |> Enum.map(fn {k, _} -> k end)

result = Enum.reduce(map_keys, Map.new(), &AOC.calc_point(map, &1, &2))

dots
|> Enum.filter(fn dot -> Map.get(result, dot) == true end)
|> length()
|> IO.puts()
