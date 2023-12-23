{:ok, str} = File.read("23.txt")

# Endpoint needs to be replaced from "." to "v"

defmodule AOC do
  @neigbour_list %{
    ">" => {1, 0},
    "<" => {-1, 0},
    "^" => {0, -1},
    "v" => {0, 1}
  }

  def parse_grid(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      String.graphemes(row)
      |> Enum.with_index()
      |> Enum.map(fn {char, x} ->
        {{x, y}, char}
      end)
    end)
    |> Map.new()
  end

  def is_valid(_, "."), do: true
  def is_valid(_, "#"), do: false
  def is_valid(d, symbol), do: d == Map.get(@neigbour_list, symbol)

  def neighbours(".") do
    Map.values(@neigbour_list)
  end

  def neighbours(direction) do
    [Map.get(@neigbour_list, direction)]
  end

  def walk_path(grid, {next_points, final_points, matrix}) do
    next_points_map = next_points |> Map.new()
    new_matrix = Map.merge(matrix, next_points_map)

    neighbours =
      next_points
      |> Enum.flat_map(fn {pt = {x, y}, dist} ->
        AOC.neighbours(Map.get(grid, pt))
        |> Enum.filter(fn d = { dx, dy } -> is_valid(d, Map.get(grid, {x + dx, y + dy}, "#")) end)
        |> Enum.map(fn { dx, dy } -> {x + dx, y + dy} end)
        |> Enum.map(fn new_pt -> {new_pt, dist + 1} end)
      end)
      |> Enum.filter(fn {pt, _dist} -> !Map.has_key?(matrix, pt) end)

    {new_next_points, new_final_points} =
      neighbours |> Enum.split_with(fn {pt, _dist} -> Map.get(grid, pt, "#") == "." end)

    {new_next_points, final_points ++ new_final_points, new_matrix}
  end

  def find_dot_paths(grid, start_points) do
    f = &walk_path(grid, &1)

    {start_points, [], Map.new()}
    |> Stream.iterate(f)
    |> Stream.drop_while(fn {new_next_points, _, _} -> Enum.count(new_next_points) > 0 end)
    |> Stream.map(fn {_, final_points, _} -> final_points end)
    |> Enum.at(0)
  end

  def find_paths(grid) do
    max_x = grid |> Map.keys() |> Enum.map(fn {x, _} -> x end) |> Enum.max()
    max_y = grid |> Map.keys() |> Enum.map(fn {_, y} -> y end) |> Enum.max()
    end_point = {max_x - 1, max_y}

    start_point = {1, 0}
    f = &find_dot_paths(grid, &1)

    [{start_point, 0}]
    |> Stream.iterate(f)
    |> Stream.take_while(fn pts -> Enum.count(pts) > 0 end)
    |> Stream.map(fn points ->
      Enum.filter(points, fn {point, _dist} -> point == end_point end)
    end)
    |> Enum.flat_map(fn x -> x end)
    |> Enum.max_by(fn {_pt, dist} -> dist end)
  end
end

str |> AOC.parse_grid() |> AOC.find_paths() |> IO.inspect()
