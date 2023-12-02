{:ok, str} = File.read("02.txt")

defmodule AOC do
  @limits %{
    "red" => 12,
    "green" => 13,
    "blue" => 14
  }

  def parse_line(line) do
    line
      |> String.split(":")
      |> Enum.at(1)
      |> String.split(~r/,|;/)
      |> Enum.map(&Regex.named_captures(~r/(?<num>\d+) (?<type>[a-z]+)/, &1))
  end

  def is_possible(game) do
    game |> Enum.all?(fn(x) -> @limits[x["type"]] >= String.to_integer(x["num"]) end)
  end
end

result =
  str
  |> String.split("\n")
  |> Enum.map(&AOC.parse_line/1)
  |> Enum.with_index(1)
  |> Enum.filter(&AOC.is_possible(elem(&1, 0)))
  |> Enum.map(&elem(&1, 1))
  |> Enum.sum()

IO.puts(result)
