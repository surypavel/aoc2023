{:ok, str} = File.read("08.txt")

defmodule AOC do
  def load_instructions(input) do
    input |> String.graphemes()
  end

  def load_maps(input) do
    [_, a, b, c] = Regex.run(~r/([1-9A-Z]+) = \(([1-9A-Z]+), ([1-9A-Z]+)\)/, input)
    {a, %{l: b, r: c}}
  end

  def make_step(input, instruction, maps) do
    map_item = Map.get(maps, input)

    if instruction == "R" do
      map_item.r
    else
      map_item.l
    end
  end

  def lcm(list) do
    gcd = Enum.reduce(list, 0, &Integer.gcd/2)
    mult = Enum.product(list)
    div(mult, gcd ** (length(list) - 1))
  end

  def lookup(inputs, destination, instructions, maps, index) do
    [current | queue] = instructions

    new_inputs =
      inputs
      |> Enum.map(&AOC.make_step(&1, current, maps))

    if Enum.member?(new_inputs, destination) do
      index
    else
      lookup(new_inputs, destination, queue ++ [current], maps, index + 1)
    end
  end
end

[instruction_string, _empty | map_string] = String.split(str, "\n")

instructions = AOC.load_instructions(instruction_string)
maps = Enum.map(map_string, &AOC.load_maps/1)

[ starting_nodes, ending_nodes ] = ["A", "Z"]
|> Enum.map(fn letter ->
  maps
  |> Enum.map(fn {src, _} -> src end)
  |> Enum.filter(fn src -> String.ends_with?(src, letter) end)
end)
ending_nodes |>
Enum.map(fn ending_node -> AOC.lookup(starting_nodes, ending_node, instructions, Map.new(maps), 1) end)
|> AOC.lcm()
|> IO.puts()
