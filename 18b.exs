{:ok, str} = File.read("18.txt")

defmodule AOC do
  def load_instruction(input) do
    [_, a, b] = Regex.run(~r/(R|D|L|U) (\d+)/, input)
    {a, b |> String.to_integer()}
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

  def calc_size_reduce({direction, steps}, {{x, y}, {max_x, max_y}}) do
    {new_x, new_y} =
      case direction do
        "L" -> {x - steps, y}
        "R" -> {x + steps, y}
        "U" -> {x, y - steps}
        "D" -> {x, y + steps}
      end

    new_max = {max(max_x, new_x), max(max_y, new_y)}
    {{new_x, new_y}, new_max}
  end

  def calc_size(arr) do
    Enum.reduce(arr, {{0, 0}, {0, 0}}, &AOC.calc_size_reduce/2) |> elem(1)
  end

  def calc_area_reduce({size_x, size_y}, {direction, steps}, {position, area}) do
    vector = AOC.get_vector(direction)
    new_position = AOC.sum(position, AOC.prod(vector, steps))

    new_area =
      case direction do
        "R" -> area + (new_position.x - position.x) * (size_y - position.y + 1)
        "L" -> area + (new_position.x - position.x) * (position.y + 1)
        "D" -> area + (new_position.y - position.y) * (size_x - position.x + 1)
        "U" -> area + (new_position.y - position.y) * (position.x + 1)
      end

    {new_position, new_area}
  end

  def calc_area(total = { width, height }, arr) do
    calc_area_reduce_fn = &AOC.calc_area_reduce(total, &1, &2)
    square_area = (width + 1) * (height + 1)
    wrapped_area = Enum.reduce(arr, {%{x: 0, y: 0}, 0}, calc_area_reduce_fn) |> elem(1)
    { wrapped_area, square_area }
  end
end

instructions =
  str
  |> String.split("\n")
  |> Enum.map(&AOC.load_instruction/1)

size = AOC.calc_size(instructions) |> IO.inspect()

AOC.calc_area(size, instructions) |> IO.inspect()
