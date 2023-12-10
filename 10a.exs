{:ok, str} = File.read("10.txt")

defmodule AOC do
  def load_map(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {char, x} -> {{x, y}, char} end)
    end)
  end

  def get_next_points({x, y}, direction) do
    case direction do
      "|" -> [{x, y - 1}, {x, y + 1}]
      "-" -> [{x - 1, y}, {x + 1, y}]
      "L" -> [{x, y - 1}, {x + 1, y}]
      "F" -> [{x + 1, y}, {x, y + 1}]
      "J" -> [{x - 1, y}, {x, y - 1}]
      "7" -> [{x - 1, y}, {x, y + 1}]
    end
  end

  # Hard-coded for my input
  def replace_start(map_point) do
    if map_point == "S" do
      "|"
    else
      map_point
    end
  end

  def check_neighbors(map, point) do
    map_point = map |> Map.get(point)

    AOC.get_next_points(point, AOC.replace_start(map_point))
  end

  def run_dijstra(map, {points, distance, ranking}) do
    new_points =
      points
      |> Enum.flat_map(&check_neighbors(map, &1))
      |> Enum.filter(fn point -> !Map.has_key?(ranking, point) end)

    new_distance = distance + 1

    new_ranking =
      ranking
      |> Map.merge(Map.new(points, fn point -> {point, new_distance} end))

    {new_points, new_distance, new_ranking}
  end

  # For part (b)
  def clean(ranking, map, size_x, size_y) do
    content =
      Enum.map(0..size_y, fn y ->
        "#{Enum.map(0..size_x, fn x -> if Map.has_key?(ranking, {x, y}) do
          AOC.replace_start(Map.get(map, {x, y}))
          else
            "."
          end end)}\n"
      end)

    File.write("10_clean.txt", content)
  end
end

input_map = str |> AOC.load_map()
map = input_map |> Map.new()
map_fn = &AOC.run_dijstra(map, &1)

start_position =
  Enum.find_value(input_map, fn {k, v} ->
    if v == "S" do
      k
    else
      nil
    end
  end)

end_state =
  {[start_position], 0, Map.new()}
  |> Stream.iterate(map_fn)
  |> Enum.take_while(fn {points, _, _} -> length(points) > 0 end)
  |> Enum.at(-1)

end_state
|> elem(1)
|> IO.puts()

# prep for part 2
size_x = str |> String.split("\n") |> Enum.at(0) |> String.length()
size_y = str |> String.split("\n") |> length()
end_state |> map_fn.() |> elem(2) |> AOC.clean(map, size_x - 1, size_y - 1)
