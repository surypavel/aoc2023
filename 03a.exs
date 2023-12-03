{:ok, str} = File.read("03.txt")

defmodule AOC do
  def find_numbers({line, index}) do
    Regex.scan(~r/\d+/, line, return: :index)
    |> Enum.flat_map(&Enum.map(&1, fn {s, e} -> {s, e, index} end))
  end

  def find_ops({line, index}) do
    Regex.scan(~r/[^\d\.]/, line, return: :index)
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
  |> Enum.flat_map(&AOC.find_ops/1)
  |> Enum.map(fn x -> {x, true} end)
  |> Map.new()

sum =
  split_str
  |> Enum.with_index()
  |> Enum.flat_map(&AOC.find_numbers/1)
  |> Enum.filter(&AOC.has_operation(AOC.get_neighbours(&1), ops))
  |> Enum.map(&AOC.as_number(&1, split_str))
  |> Enum.sum()

IO.puts(sum)
