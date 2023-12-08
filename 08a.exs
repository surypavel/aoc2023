{:ok, str} = File.read("08.txt")

defmodule AOC do
  def load_instructions(input) do
    input |> String.graphemes()
  end

  def load_maps(input) do
    [_, a, b, c] = Regex.run(~r/([A-Z]+) = \(([A-Z]+), ([A-Z]+)\)/, input)
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

  def lookup(input, destination, instructions, maps, index) do
    [current | queue] = instructions

    new_input = AOC.make_step(input, current, maps)

    if new_input == destination do
      index
    else
      lookup(new_input, destination, queue ++ [current], maps, index + 1)
    end
  end
end

[instruction_string, _empty | map_string] = String.split(str, "\n")

instructions = AOC.load_instructions(instruction_string)

maps =
  map_string
  |> Enum.map(&AOC.load_maps/1)
  |> Map.new()

AOC.lookup("AAA", "ZZZ", instructions, maps, 1) |> IO.inspect()
