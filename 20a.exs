{:ok, str} = File.read("20.txt")

defmodule AOC do
  def parse_module(module_str) do
    [_, type, name, modules] = Regex.run(~r/^(%|&)?([a-z]+) -> (.+)/, module_str)
    {name, %{type: type, modules: String.split(modules, ", ")}}
  end

  def send_pulses(modules, {flip_flops, conjunctions, pulses}) do
    xx =
      Enum.map(pulses, fn {where, is_low} ->
        origin = Map.get(modules, where)

        new =
          cond do
            origin == nil ->
              {Map.new(), Map.new(), []}

            origin.type == "%" and is_low == false ->
              {Map.new(), Map.new(), []}

            origin.type == "%" and is_low == true ->
              on = flip_flops |> Map.get(where, false)

              x = Enum.map(origin.modules, fn destination_module -> {destination_module, on} end)

              y =
                Enum.reduce(origin.modules, Map.new(), fn destination_module, acc ->
                  Map.put(acc, {where, destination_module}, on)
                end)

              {Map.new([{where, !on}]), y, x}

            origin.type == "&" ->
              remembered_value =
                Map.to_list(conjunctions)
                |> Enum.filter(fn {{_, w}, _} -> where == w end)
                |> Enum.all?(fn {_, prev} -> prev == true end)

              y =
                Enum.reduce(origin.modules, Map.new(), fn destination_module, acc ->
                  Map.put(acc, {where, destination_module}, !remembered_value)
                end)

              {Map.new(), y,
               Enum.map(origin.modules, fn destination_module ->
                 {destination_module, !remembered_value}
               end)}

            origin.type == "" ->
              y =
                Enum.reduce(origin.modules, Map.new(), fn destination_module, acc ->
                  Map.put(acc, {where, destination_module}, is_low)
                end)

              {Map.new(), y,
               Enum.map(origin.modules, fn destination_module -> {destination_module, is_low} end)}
          end

        elem(new, 2)
        |> Enum.map(fn {dest, low} ->
          IO.puts(
            "#{where} -#{if low do
              "low"
            else
              "high"
            end}-> #{dest}"
          )
        end)

        new
      end)

    Enum.reduce(xx, {flip_flops, conjunctions, []}, fn {f2, c2, a2}, {f, c, a} ->
      {Map.merge(f, f2), Map.merge(c, c2), a ++ a2}
    end)
  end

  def push_button(modules, {{flip_flops, conjunctions}, _}) do
    init_state = {flip_flops, conjunctions, [{"broadcaster", true}]}
    f = &send_pulses(modules, &1)

    stream =
      Stream.iterate(init_state, f)
      |> Enum.take_while(fn {_, _, new_pulses} -> Enum.count(new_pulses) > 0 end)

    last_state =
      stream
      |> Enum.at(-1)
      |> (fn {x, y, _} -> {x, y} end).()

    counts =
      stream
      |> Enum.flat_map(fn {_, _, new_pulses} -> Enum.map(new_pulses, fn {_, low} -> low end) end)
      |> Enum.frequencies()

    IO.puts("")

    {last_state, counts}
  end

  def push_button_1000(modules) do
    init_state = {{Map.new(), Map.new()}, %{true: 0, false: 0}}
    f = &push_button(modules, &1)

    Stream.iterate(init_state, f)
    |> Stream.take(11)
    |> Enum.reduce(%{true: 0, false: 0}, fn {_, nums}, acc ->
      %{true: acc.true + nums.true, false: acc.false + nums.false}
    end)
    |> (fn nums -> nums.true * nums.false end).()
    |> IO.inspect()
  end
end

str
|> String.split("\n")
|> Map.new(&AOC.parse_module/1)
|> IO.inspect()
|> AOC.push_button_1000()
|> IO.inspect()
