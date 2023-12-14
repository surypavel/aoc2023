{:ok, str} = File.read("14.txt")

defmodule AOC do
  def load_input(str) do
    rows = str |> String.split("\n")

    rows
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.join/1)
  end

  def tilt_load(columns) do
    columns
    |> Enum.map(fn column ->
      column
      |> String.split("#")
      |> Enum.map(fn part -> part |> String.graphemes() |> Enum.sort(:desc) |> Enum.join() end)
      |> Enum.join("#")
      |> String.graphemes()
    end)
  end

  def calc_load(columns) do
    columns
    |> Enum.map(fn column ->
      column
      |> Enum.reverse()
      |> Enum.with_index(1)
      |> Enum.filter(fn {char, _} -> char == "O" end)
      |> Enum.map(&elem(&1, 1))
      |> Enum.sum()
    end)
    |> Enum.sum()
  end
end

str
|> AOC.load_input()
|> AOC.tilt_load()
|> AOC.calc_load()
|> IO.puts()
