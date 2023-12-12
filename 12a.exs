{:ok, str} = File.read("12.txt")

defmodule AOC do
  def parse_line(str) do
    [records, checksum] = String.split(str, " ")
    # Add . to the beginning for easier parsing
    {".#{records}", String.split(checksum, ",") |> Enum.map(&String.to_integer/1)}
  end

  def calc_possibilities({"", []}), do: 1
  def calc_possibilities({"", _}), do: 0
  def calc_possibilities({".", []}), do: 1
  def calc_possibilities({".", _}), do: 0
  def calc_possibilities({"#" <> _tail, _}), do: 0
  def calc_possibilities({".#" <> _tail, []}), do: 0

  def calc_possibilities({".." <> tail, checksum}),
    do: AOC.calc_possibilities({"." <> tail, checksum})

  def calc_possibilities({"?" <> tail, checksum}) do
    a = AOC.calc_possibilities({"." <> tail, checksum})
    b = AOC.calc_possibilities({"#" <> tail, checksum})
    a + b
  end

  def calc_possibilities({".?" <> tail, checksum}) do
    a = AOC.calc_possibilities({".." <> tail, checksum})
    b = AOC.calc_possibilities({".#" <> tail, checksum})
    a + b
  end

  def calc_possibilities({".#" <> tail, [instruction | rest]}) do
    {prev, next} = String.split_at(tail, instruction - 1)
    consistent = !String.contains?(prev, ".") and String.length(prev) == instruction - 1

    if consistent do
      AOC.calc_possibilities({next, rest})
    else
      0
    end
  end
end

str
|> String.split("\n")
|> Enum.map(fn line ->
  line |> AOC.parse_line() |> AOC.calc_possibilities()
end)
|> IO.inspect()
|> Enum.sum()
|> IO.puts()
