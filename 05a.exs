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

  def lookup(map, item) do
    mapping =
      Enum.find(map, fn [_dst_rng_start, src_rng_start, len] ->
        src_rng_start <= item and item < src_rng_start + len
      end)

    if mapping == nil do item else Enum.at(mapping, 0) + (item - Enum.at(mapping, 1)) end
  end
end

[seed_string | map_string] = str |> String.split("\n\n")

seeds = AOC.load_numbers(seed_string)
maps = Enum.map(map_string, &AOC.load_map/1)

Enum.map(seeds, fn seed -> Enum.reduce(maps, seed, &AOC.lookup/2) end) |> Enum.min() |> IO.puts()
