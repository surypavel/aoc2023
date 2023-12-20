{:ok, str} = File.read("18.txt")

defmodule AOC do
  # Part 1
  def load_instruction(input) do
    [_, a, b] = Regex.run(~r/(R|D|L|U) (\d+)/, input)
    {a, b |> String.to_integer()}
  end

  # Part 2
  def load_instruction_hex(input) do
    [_, a, b] = Regex.run(~r/\(#([a-f0-9]+)([a-f0-9])\)/, input)
    direction = case b do
      "0" -> "R"
      "1" -> "D"
      "2" -> "L"
      "3" -> "U"
    end
    {distance, ""} = Integer.parse(a, 16)
    {direction, distance}
  end

  def get_vector(direction) do
    case direction do
      "L" -> %{x: -1, y: 0}
      "R" -> %{x: 1, y: 0}
      "U" -> %{x: 0, y: -1}
      "D" -> %{x: 0, y: 1}
    end
  end

  def sum(a, b) do
    %{x: a.x + b.x, y: a.y + b.y}
  end

  def prod(a, k) do
    %{x: a.x * k, y: a.y * k}
  end

  def calc_size_reduce({direction, steps}, {{x, y}, {max_x, max_y}, {min_x, min_y}}) do
    {new_x, new_y} =
      case direction do
        "L" -> {x - steps, y}
        "R" -> {x + steps, y}
        "U" -> {x, y - steps}
        "D" -> {x, y + steps}
      end

    new_max = {max(max_x, new_x), max(max_y, new_y)}
    new_min = {min(min_x, new_x), min(min_y, new_y)}
    {{new_x, new_y}, new_max, new_min}
  end

  def calc_size(arr) do
    {_, max, min} =
      Enum.reduce(arr, {{0, 0}, {0, 0}, {0, 0}}, &AOC.calc_size_reduce/2)

    {max, min}
  end

  def calc_area_reduce({{max_x, max_y}, {min_x, min_y}}, {direction, steps}, {position, area}) do
    vector = AOC.get_vector(direction)
    new_position = AOC.sum(position, AOC.prod(vector, steps))

    diff =
      case direction do
        "R" -> (new_position.x - position.x) * (max_y - min_y - position.y + 1)
        "L" -> (new_position.x - position.x) * (max_y - min_y - position.y)
        "D" -> 0
        "U" -> 0
      end

    {new_position, area + diff}
  end

  def calc_area(sizes, arr) do
    calc_area_reduce_fn = &AOC.calc_area_reduce(sizes, &1, &2)
    Enum.reduce(arr, {%{x: 0, y: 0}, 0}, calc_area_reduce_fn) |> elem(1)
  end
end

instructions =
  str
  |> String.split("\n")
  |> Enum.map(&AOC.load_instruction_hex/1)

u =
  Enum.filter(instructions, fn {i, _v} -> i == "U" end)
  |> Enum.map(fn {_i, v} -> v end)
  |> Enum.sum()

size = AOC.calc_size(instructions)

(1 + u + AOC.calc_area(size, instructions)) |> IO.inspect()
