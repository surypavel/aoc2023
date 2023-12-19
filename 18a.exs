{:ok, str} = File.read("18.txt")

defmodule AOC do
  @directions [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def load_instruction(input) do
    [_, a, b] = Regex.run(~r/(R|D|L|U) (\d+)/, input)
    {a, b |> String.to_integer()}
  end

  def get_vector(direction) do
    case direction do
      "L" -> {-1, 0}
      "R" -> {1, 0}
      "U" -> {0, -1}
      "D" -> {0, 1}
    end
  end

  def sum({x1, y1}, {x2, y2}) do
    {x1 + x2, y1 + y2}
  end

  def prod({x1, y1}, k) do
    {x1 * k, y1 * k}
  end

  def walk_along({direction, steps}, acc = [head | _]) do
    vector = AOC.get_vector(direction)

    added =
      steps..1
      |> Enum.map(fn k ->
        AOC.sum(head, AOC.prod(vector, k))
      end)

    added ++ acc
  end

  def bucket_fill_one(outline_map, {digged, queue}) do
    digged_new = Map.merge(digged, Map.new(queue, fn item -> {item, true} end))

    queue_new =
      queue
      |> Enum.flat_map(fn item -> Enum.map(@directions, &AOC.sum(item, &1)) end)
      |> Enum.uniq()
      |> Enum.filter(fn item ->
        !Map.has_key?(digged_new, item) and !Map.has_key?(outline_map, item)
      end)

    {digged_new, queue_new}
  end

  def bucket_fill(outline) do
    outline_map = Map.new(outline, fn item -> {item, true} end)
    bucket_fn = &bucket_fill_one(outline_map, &1)

    {digged, last} =
      {Map.new(), [{1, 1}]}
      |> Stream.iterate(bucket_fn)
      |> Enum.take_while(fn {_digged, queue} -> Enum.count(queue) > 0 end)
      |> Enum.at(-1)

    Map.to_list(digged)
  end
end

outline =
  str
  |> String.split("\n")
  |> Enum.map(&AOC.load_instruction/1)
  |> Enum.reduce([{0, 0}], &AOC.walk_along/2)

filling = AOC.bucket_fill(outline) |> IO.inspect()

(Enum.count(outline) + Enum.count(filling)) |> IO.puts()
