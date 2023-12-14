{:ok, str} = File.read("14.txt")

defmodule AOC do
  def transpose_rows(rows) do
    rows
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.join/1)
  end

  def load_input(str) do
    rows = str |> String.split("\n")
    columns = AOC.transpose_rows(rows)
    {rows, columns}
  end

  def tilt(lines, direction) do
    lines
    |> Enum.map(fn line ->
      line
      |> String.split("#")
      |> Enum.map(fn part -> part |> String.graphemes() |> Enum.sort(direction) |> Enum.join() end)
      |> Enum.join("#")
    end)
  end

  def tilt_load({rows, columns}, orientation) do
    flag =
      if orientation == 0 or orientation == 1 do
        :desc
      else
        :asc
      end

    items =
      if orientation == 0 or orientation == 2 do
        columns
      else
        rows
      end

    items = AOC.tilt(items, flag)
    transposed = AOC.transpose_rows(items)

    if orientation == 0 or orientation == 2 do
      {transposed, items}
    else
      {items, transposed}
    end
  end

  def tilt_cycle(def) do
    def
    |> AOC.tilt_load(0)
    |> AOC.tilt_load(1)
    |> AOC.tilt_load(2)
    |> AOC.tilt_load(3)
  end

  def calc_load({_, columns}) do
    columns
    |> Enum.map(fn column ->
      column
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.with_index(1)
      |> Enum.filter(fn {char, _} -> char == "O" end)
      |> Enum.map(&elem(&1, 1))
      |> Enum.sum()
    end)
    |> Enum.sum()
  end
end

input = AOC.load_input(str)

{_, _, second, first} = Stream.iterate({input, Map.new(), 0, nil}, fn {val, map, index, _} ->
  new_val = AOC.tilt_cycle(val)
  {current_value, new_map} = Map.get_and_update(map, :erlang.phash2(val), fn x -> { x, index } end)
  {new_val, new_map, index + 1, current_value}
end)
|> Stream.drop_while(fn { _, _, _, current_value} -> current_value == nil end)
|> Stream.take(1)
|> Enum.at(0)

period = second - first - 1
count = Integer.mod(1000000000 - first, period) + first

input
|> Stream.iterate(fn prev -> AOC.tilt_cycle(prev) end)
|> Stream.take(count + 1)
|> Stream.map(&AOC.calc_load(&1))
|> Enum.at(-1)
|> IO.puts()
