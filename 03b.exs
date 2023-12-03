{:ok, str} = File.read("03.txt")

defmodule AOC do
  def find_numbers({line, index}) do
    Regex.scan(~r/\d+/, line, return: :index)
    |> Enum.flat_map(&Enum.map(&1, fn {s, e} -> {s, e, index} end))
  end

  def find_multi({line, index}) do
    Regex.scan(~r/\*/, line, return: :index)
    |> Enum.flat_map(&Enum.map(&1, fn {num, _} -> {num, index} end))
  end

  def get_neighbours({left, width, top}) do
    horizontal_neigbours = [{left - 1, top}, {left + width, top}]

    vertical_neighbours =
      (left - 1)..(left + width)
      |> Enum.flat_map(fn x -> [{x, top + 1}, {x, top - 1}] end)

    horizontal_neigbours ++ vertical_neighbours
  end

  def has_operation(list, ops) do
    Enum.any?(list, fn item -> Map.has_key?(ops, item) end)
  end

  def as_number({left, width, top}, split_str) do
    split_str
    |> Enum.at(top)
    |> String.slice(left, width)
    |> String.to_integer()
  end
end

split_str = String.split(str, "\n")

ops =
  split_str
  |> Enum.with_index()
  |> Enum.flat_map(&AOC.find_multi/1)

numbers =
  split_str
  |> Enum.with_index()
  |> Enum.flat_map(&AOC.find_numbers/1)

gears =
  ops
  |> Enum.map(fn op -> Enum.filter(numbers, fn number -> AOC.has_operation(AOC.get_neighbours(number), Map.new([{op, true}])) end) end)
  |> Enum.filter(fn numbers -> length(numbers) == 2 end)

gear_sizes = gears
  |> Enum.map(fn [gear1, gear2] -> AOC.as_number(gear1, split_str) * AOC.as_number(gear2, split_str) end)
  |> Enum.sum()

IO.puts(gear_sizes)
