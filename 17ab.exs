{:ok, str} = File.read("17.txt")

defmodule AOC do
  # Tweak these constants until you get a result
  # Setup for (b)
  @max_result 1095
  @max_steps 1000
  @min_straight 4
  @max_straight 10

  # Setup for (a)
  # @min_straight 1
  # @max_straight 3
  # @max_result 1000
  # @max_steps 1000

  def parse_grid(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      String.graphemes(row)
      |> Enum.with_index()
      |> Enum.map(fn {char, x} ->
        {{x, y}, String.to_integer(char)}
      end)
    end)
    |> Map.new()
  end

  def turns(nil) do
    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
  end

  def turns({dx, dy}) do
    [{dy, dx}, {-dy, -dx}]
  end

  def sum({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end

  def prodx({x1, y1}, k) do
    {x1 * k, y1 * k}
  end

  def navigate(map, arg) do
    arg.direction
    |> AOC.turns()
    |> Enum.flat_map(fn new_direction ->
      Enum.flat_map((@min_straight..@max_straight), fn step_size ->
        direction_mult = AOC.prodx(new_direction, step_size)

        heat_loss =
          1..step_size
          |> Enum.map(fn over ->
            Map.get(map, AOC.sum(arg.point, AOC.prodx(new_direction, over)))
          end)

        if Enum.all?(heat_loss, fn item -> item != nil end) do
          [
            %{
              point: AOC.sum(arg.point, direction_mult),
              direction: new_direction,
              steps: arg.steps + Enum.sum(heat_loss)
            }
          ]
        else
          []
        end
      end)
    end)
  end

  def key(item) do
    {x, _} = item.direction
    {item.point, x == 0}
  end

  def navigate_all(map, {dijkstra_map, mult}) do
    new_mult =
      Enum.flat_map(mult, &AOC.navigate(map, &1))
      |> Enum.filter(fn item ->
        best_score = Map.get(dijkstra_map, AOC.key(item))

        (best_score == nil or item.steps < best_score) and item.steps < @max_result
      end)
      |> Enum.uniq()

    new_dijkstra_map =
      Map.merge(dijkstra_map, Map.new(new_mult, fn t -> {AOC.key(t), t.steps} end))

    {new_dijkstra_map, new_mult}
  end

  def find_shortest_path_between(grid_map, start_position, final_position) do
    navigate_fn = &AOC.navigate_all(grid_map, &1)

    final_map =
      {Map.new(), [%{steps: 0, point: start_position, direction: nil}]}
      |> Stream.iterate(navigate_fn)
      |> Enum.take(@max_steps)
      |> Enum.at(-1)
      |> elem(0)

    distances =
      for direction <- [true, false],
          do: Map.get(final_map, {final_position, direction})

    Enum.min(distances)
  end
end

grid_map = str |> AOC.parse_grid()

# hard-coded for input
end_point = {140, 140}

grid_map
|> AOC.find_shortest_path_between({0, 0}, end_point) |> IO.inspect()
