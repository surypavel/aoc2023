{:ok, str} = File.read("23.txt")

defmodule AOC do
  @neigbours [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]

  @neigbour_list %{
    ">" => {1, 0},
    "<" => {-1, 0},
    "^" => {0, -1},
    "v" => {0, 1}
  }

  @reverse_list %{
    {1, 0} => ">",
    {-1, 0} => "<",
    {0, -1} => "^",
    {0, 1} => "v"
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

  def walk_path({grid, mid_points}, {next_points, dist, final_points, matrix}) do
    next_points_map = next_points |> Map.new(fn pt -> {pt, true} end)
    new_matrix = Map.merge(matrix, next_points_map)

    neighbours =
      next_points
      |> Enum.flat_map(fn pt = {x, y} ->
        @neigbours
        |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
        |> Enum.filter(fn new_pt -> Map.get(grid, new_pt, "#") != "#" end)
        |> Enum.filter(fn new_pt -> !Map.has_key?(new_matrix, new_pt) end)
      end)

    {new_final_points, new_next_points} =
      neighbours |> Enum.split_with(fn pt -> Enum.member?(mid_points, pt) end)

    {
      new_next_points,
      dist + 1,
      final_points ++ (new_final_points |> Enum.map(fn pt -> {pt, dist + 1} end)),
      new_matrix
    }
  end

  def find_dot_paths({grid, mid_points}, start_points) do
    f = &walk_path({grid, mid_points}, &1)

    {start_points, 0, [], Map.new()}
    |> Stream.iterate(f)
    |> Stream.drop_while(fn {new_next_points, _, _, _} -> Enum.count(new_next_points) > 0 end)
    |> Stream.map(fn {_, _, final_points, _} -> final_points end)
    |> Enum.at(0)
  end

  def find_paths(grid) do
    max_x = grid |> Map.keys() |> Enum.map(fn {x, _} -> x end) |> Enum.max()
    max_y = grid |> Map.keys() |> Enum.map(fn {_, y} -> y end) |> Enum.max()
    end_point = {max_x - 1, max_y}

    start_point = {1, 0}
    f = &find_dot_paths(grid, &1)

    grid_starting =
      Map.merge(
        grid,
        Map.filter(grid, fn {k, v} -> v != "." and v != "#" end)
        |> Map.keys()
        |> Map.new(fn k -> {k, "."} end)
      )

    [{start_point, 0, grid_starting}]
    |> Stream.iterate(f)
    # |> Enum.take(3)
    # |> Enum.at(-1)
    # |> Enum.map(fn {pt, dist, grid_x} ->
    #   grid_x |> debug()
    #   {pt, dist}
    # end)

    |> Stream.take_while(fn pts -> Enum.count(pts) > 0 end)
    |> Stream.map(fn points ->
      Enum.filter(points, fn {point, _dist, _grid_x} -> point == end_point end)
    end)
    |> Enum.map(fn x ->
      if Enum.count(x) > 0 do
        IO.inspect(Enum.map(x, fn xx -> elem(xx, 1) end) |> Enum.max())
      end

      x
    end)
    |> Enum.flat_map(fn x -> x end)
    |> Enum.map(fn {_pt, dist, _grid_x} -> dist end)
    |> Enum.max()
  end

  def find_mid_points(grid) do
    grid
    |> Map.keys()
    |> Enum.filter(fn pt = {x, y} ->
      in_area =
        @neigbours
        |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
        |> Enum.map(fn pt -> Map.get(grid, pt, "#") end)
        |> Enum.filter(fn x -> x != "#" end)
        |> Enum.count()
        |> Kernel.>=(3)

      is_reachable = Map.get(grid, pt, "#") != "#"
      is_reachable and in_area
    end)
  end

  def find_end_point(grid) do
    max_x = grid |> Map.keys() |> Enum.map(fn {x, _} -> x end) |> Enum.max()
    max_y = grid |> Map.keys() |> Enum.map(fn {_, y} -> y end) |> Enum.max()
    {max_x - 1, max_y}
  end

  def debug(map) do
    for i <- 0..22 do
      for j <- 0..22 do
        IO.write(Map.get(map, {j, i}))
      end

      IO.puts("")
    end

    IO.puts("")
  end

  def find_longest_path(paths, start_pt, end_pt, visited) do
    if start_pt == end_pt do
      0
    else
      start_paths =
        Map.get(paths, start_pt)
        |> Enum.filter(fn {pt, dist} -> !Enum.member?(visited, pt) end)

      next_possible =
        Enum.map(start_paths, fn {pt, dist} ->
          dist + find_longest_path(paths, pt, end_pt, [start_pt | visited])
        end)

      if Enum.count(next_possible) == 0 do
        -1_000_000
      else
        Enum.max(next_possible)
      end
    end
  end
end

grid = str |> AOC.parse_grid()
end_point = grid |> AOC.find_end_point()
start_point = {1, 0}
mid_points = grid |> AOC.find_mid_points()
interesting_points = [start_point, end_point | mid_points]

paths =
  interesting_points
  |> Map.new(fn point ->
    {point, AOC.find_dot_paths({grid, interesting_points}, [point])}
  end)

AOC.find_longest_path(paths, start_point, end_point, []) |> IO.inspect()
