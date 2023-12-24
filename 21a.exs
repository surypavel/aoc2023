{:ok, str} = File.read("21.txt")

defmodule AOC do
  @directions [{0, 1}, {1, 0}, {-1, 0}, {0, -1}]

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

  def navigate(map, {points, visited, dist}) do
    new_visited = Map.merge(visited, Map.new(points, fn point -> {point, dist} end))

    intermediate_points =
      points
      |> Enum.flat_map(fn {px, py} ->
        @directions
        |> Enum.map(fn {dx, dy} -> {dx + px, dy + py} end)
        |> Enum.filter(fn point -> Map.get(map, point, "#") == "." end)
        |> Enum.filter(fn point -> !Map.has_key?(new_visited, point) end)
      end)
      |> Enum.uniq()

    new_points =
      intermediate_points
      |> Enum.flat_map(fn {px, py} ->
        @directions
        |> Enum.map(fn {dx, dy} -> {dx + px, dy + py} end)
        |> Enum.filter(fn point -> Map.get(map, point, "#") == "." end)
        |> Enum.filter(fn point -> !Map.has_key?(new_visited, point) end)
      end)
      |> Enum.uniq()

    {new_points, new_visited, dist + 2}
  end

  def iterate_navigate(grid) do
    starting_point = Map.filter(grid, fn {_, v} -> v == "S" end) |> Map.keys() |> Enum.at(0)
    starting_state = {[starting_point], Map.new(), 0}
    iterate_fn = &navigate(grid, &1)

    Stream.iterate(starting_state, iterate_fn)
    |> Stream.drop(33)
    |> Enum.at(0)
    |> elem(1)
    |> Map.keys()
    |> Enum.count()
  end
end

str |> AOC.parse_grid() |> AOC.iterate_navigate() |> IO.inspect()
