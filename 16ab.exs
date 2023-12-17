{:ok, str} = File.read("16.txt")

defmodule AOC do
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

  def sum({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end

  def mov(point, direction) do
    {AOC.sum(point, direction), direction}
  end

  def get_new_direction(nil, _), do: []
  def get_new_direction(".", direction), do: [direction]
  def get_new_direction("-", direction = {_, 0}), do: [direction]
  def get_new_direction("|", direction = {0, _}), do: [direction]
  def get_new_direction("\\", {dx, dy}), do: [{dy, dx}]
  def get_new_direction("/", {dx, dy}), do: [{-dy, -dx}]
  def get_new_direction("-", {0, _}), do: [{1, 0}, {-1, 0}]
  def get_new_direction("|", {_, 0}), do: [{0, 1}, {0, -1}]

  def navigate(map, {point, direction}) do
    map
    |> Map.get(point)
    |> AOC.get_new_direction(direction)
    |> Enum.map(&AOC.mov(point, &1))
    |> Enum.filter(fn {point, _} -> Map.has_key?(map, point) end)
  end

  def navigate_all(map, mult) do
    mult
    |> Enum.flat_map(&AOC.navigate(map, &1))
    |> Enum.uniq()
  end

  def reduce_fn(curr, acc) do
    new = MapSet.union(acc, MapSet.new(curr))

    flag =
      if Enum.count(new) == Enum.count(acc) do
        :halt
      else
        :cont
      end

    {flag, new}
  end

  def calc_energize_from(grid_map, pd) do
    navigate_fn = &AOC.navigate_all(grid_map, &1)

    [pd]
    |> Stream.iterate(navigate_fn)
    |> Enum.reduce_while(MapSet.new(), &AOC.reduce_fn/2)
    |> Enum.map(fn {point, _direction} -> point end)

    # At this point, it should filter out all directions i already went
    # But i would need an extra variable in the reduce.
    |> Enum.uniq()
    |> Enum.count()
  end

  # def debug(points1, points2) do
  #   for i <- 0..9 do
  #     for j <- 0..9 do
  #       IO.write(
  #         if Enum.member?(points2, {j, i}) do
  #           "0"
  #         else
  #           if Enum.member?(points1, {j, i}) do
  #             "#"
  #           else
  #             "."
  #           end
  #         end
  #       )
  #     end

  #     IO.puts("")
  #   end

  #   IO.puts("")
  # end
end

grid_map = str |> AOC.parse_grid()

IO.write("Part 1: ")

grid_map
|> AOC.calc_energize_from({{0, 0}, {1, 0}})
|> IO.puts()

p1s = 0..109 |> Enum.map(fn y -> {{0, y}, {1, 0}} end)
p2s = 0..109 |> Enum.map(fn y -> {{109, y}, {-1, 0}} end)
p3s = 0..109 |> Enum.map(fn x -> {{x, 0}, {0, 1}} end)
p4s = 0..109 |> Enum.map(fn x -> {{x, 109}, {0, -1}} end)
start_points = p1s ++ p2s ++ p3s ++ p4s

# Pretty long runtime (few minutes) but too lazy to do it better.
IO.write("Part 2: ")

start_points
|> Enum.map(fn start_point -> {start_point, AOC.calc_energize_from(grid_map, start_point)} end)
|> Enum.max_by(fn { _start_point, path_size } -> path_size end)
|> IO.inspect()
