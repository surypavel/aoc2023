{:ok, str} = File.read("15.txt")

defmodule AOC do
  def hash(str) do
    str
    |> String.to_charlist()
    |> Enum.reduce(0, fn curr, acc -> Integer.mod((acc + curr) * 17, 256) end)
  end

  def parse_command(str) do
    if String.ends_with?(str, "-") do
      {String.slice(str, 0..-2)}
    else
      [x, y] = String.split(str, "=")
      {x, String.to_integer(y)}
    end
  end

  def focusing_power(box_number, box_index, lens = {_, focal}) do
    (1 + box_number) * box_index * focal
  end

  def box_add(lens = {label, _}, boxes) do
    box = AOC.hash(label)

    Map.get_and_update(boxes, box, fn value ->
      if value == nil do
        {0, [lens]}
      else
        index = Enum.find_index(value, fn {box_label, _} -> box_label == label end)
        if (index != nil) do
          {0, List.replace_at(value, index, lens)}
        else
          {0, value ++ [lens]}
        end
      end
    end)
    |> elem(1)
  end

  def box_add(lens = {label}, boxes) do
    box = AOC.hash(label)

    Map.get_and_update(boxes, box, fn value ->
      if value == nil do
        {0, []}
      else
        {0, value |> Enum.filter(fn {box_label, _} -> box_label != label end)}
      end
    end)
    |> elem(1)
  end
end

str
|> String.split(",")
|> Enum.map(&AOC.parse_command/1)
|> Enum.reduce(Map.new(), fn curr, acc -> AOC.box_add(curr, acc) end)
|> Map.to_list()
|> Enum.flat_map(fn {box_number, boxes} ->
  boxes
  |> Enum.with_index(1)
  |> Enum.map(fn {lens, box_index} -> AOC.focusing_power(box_number, box_index, lens) end)
end)
|> Enum.sum()
|> IO.inspect()
