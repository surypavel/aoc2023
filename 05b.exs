{:ok, str} = File.read("05.txt")

defmodule AOC do
  def load_numbers(input) do
    Regex.scan(~r/\d+/, input)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
  end

  def load_map(str) do
    str
    |> String.split("\n")
    |> Enum.drop(1)
    |> Enum.map(&AOC.load_numbers/1)
  end

  def lookup(map, ranges) do
    ranges
    |> Enum.flat_map(fn range -> lookup_range(map, range) end)
  end

  def intersect_ranges(dst, {s1, l1}, {s2, l2}) do
    left = Enum.max([s1, s2])
    right = Enum.min([s1 + l1, s2 + l2])

    if left < right do
      [[left - (s2 - dst), left, right - left]]
    else
      []
    end
  end

  def fill_blanks(map, {range_start, range_len}) do
    range_end = range_start + range_len
    map_updated = map ++ [[range_end, range_end, 0]]

    Enum.reduce(map_updated, [[range_start, range_start, 0]], fn map_item, acc ->
      [_dest, map_start, map_len] = Enum.at(acc, -1)
      prev_start = map_start + map_len

      acc ++ [[prev_start, prev_start, Enum.at(map_item, 1) - prev_start], map_item]
    end) |> Enum.filter(fn [_, _, l] -> l > 0 end)
  end

  def lookup_range(map, range) do
    Enum.flat_map(map, fn [dst, map_item_start, map_item_len] ->
      intersect_ranges(dst, range, {map_item_start, map_item_len})
    end)
    |> fill_blanks(range)
    |> Enum.map(fn [dst, _src, len] -> {dst, len} end)
  end
end

[seed_string | map_string] = str |> String.split("\n\n")

seed_ranges =
  AOC.load_numbers(seed_string) |> Enum.chunk_every(2) |> Enum.map(fn [a, b] -> {a, b} end)

maps =
  map_string
  |> Enum.map(&AOC.load_map/1)
  |> Enum.map(&Enum.sort_by(&1, fn x -> Enum.at(x, 1) end))

result =
  seed_ranges
  |> Enum.flat_map(fn seed_range -> Enum.reduce(maps, [seed_range], &AOC.lookup/2) end)
  |> Enum.map(&elem(&1, 0))
  |> Enum.min()

IO.puts(result)
