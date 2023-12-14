{:ok, str} = File.read("12.txt")

# 7674

defmodule Math do
  def factorial(0), do: 1

  def factorial(n) when n > 0 do
    n * factorial(n - 1)
  end

  def comb(n, k) do
    div(Math.factorial(n), Math.factorial(k) * Math.factorial(n - k))
  end
end

defmodule AOC do
  def parse_line(str) do
    [records_1, checksum_1] = String.split(str, " ")
    records = 1..5 |> Enum.map(fn _ -> records_1 end) |> Enum.join("?")
    checksum = 1..5 |> Enum.map(fn _ -> checksum_1 end) |> Enum.join(",")

    {
      records |> String.replace(~r/\.+/, ".") |> String.trim(".") |> String.split("."),
      String.split(checksum, ",") |> Enum.map(&String.to_integer/1)
    }
  end

  def _calc_possibilities({"", []}), do: 1
  def _calc_possibilities({"", _}), do: 0
  def _calc_possibilities({"#" <> _tail, []}), do: 0

  def _calc_possibilities({"#" <> tail, [instruction | rest]}) do
    {prev, next} = String.split_at(tail, instruction)
    length_diff = String.length(prev) - instruction
    consistent = length_diff == -1 or (String.ends_with?(prev, "?") and length_diff == 0)

    if consistent do
      AOC._calc_possibilities({next, rest})
    else
      0
    end
  end

  def _calc_possibilities({str, instructions}) do
    q_count = str |> String.split("#") |> Enum.at(0) |> String.length()
    {part1, part2} = String.split_at(str, q_count)

    if String.length(part2) == 0 do
      AOC._calc_possibilities_optimised({str, instructions})
    else
      part2_end = String.slice(part2, 1..-1)

      dots =
        if String.length(part2_end) > 0 do
          AOC.calc_possibilities({[part1, part2_end], instructions})
        else
          AOC._calc_possibilities_optimised({part1, instructions})
        end

      qs = AOC._calc_possibilities({"#{part1}?#{part2_end}", instructions})
      qs - dots
    end
  end

  def _calc_possibilities({"?" <> tail, checksum}) do
    a = AOC._calc_possibilities({tail, checksum})
    b = AOC._calc_possibilities({"#" <> tail, checksum})
    a + b
  end

  def _calc_possibilities_optimised({str, instructions}) do
    space = Enum.count(instructions) + Enum.sum(instructions) - 1
    diff = String.length(str) - space
    n = Enum.count(instructions) + diff
    k = diff

    if diff >= 0 do
      Math.comb(n, k)
    else
      0
    end
  end

  def makes_sense(x, y) do
    map_sharps = Enum.sum(x)
    map_dots = Enum.count(x) - 1
    freq = Enum.frequencies(y)
    sharps = Map.get(freq, "#", 0)
    dots = Map.get(freq, ".", 0)
    qs = Map.get(freq, "?", 0)

    # ["???###?...", [2, 3]]
    map_sharps >= sharps and
      map_sharps + map_dots <= Enum.count(y) and
      sharps + qs >= map_sharps and
      dots + qs >= map_dots
  end

  def calc_possibilities({[], []}), do: 1
  def calc_possibilities({[], _}), do: 0

  def calc_possibilities({[head | tail], instructions}) do
    all_q = String.match?(head, Regex.compile!("^\\?+$"))

    s =
      instructions
      |> Enum.with_index()
      |> Enum.map(fn {_, i} ->
        instruction_slice = instructions |> Enum.slice(0..i)

        if !AOC.makes_sense(instruction_slice, String.graphemes(head)) do
          0
        else
          x =
            if all_q do
              AOC._calc_possibilities_optimised({head, instruction_slice})
            else
              AOC._calc_possibilities({head, instruction_slice})
            end

          if x > 0 do
            x * AOC.calc_possibilities({tail, Enum.drop(instructions, i + 1)})
          else
            0
          end
        end
      end)
      |> Enum.sum()

    result =
      if all_q do
        AOC.calc_possibilities({tail, instructions}) + s
      else
        s
      end

    result
  end
end

str
|> String.split("\n")
|> Enum.map(fn line ->
  line |> AOC.parse_line() |> AOC.calc_possibilities() |> IO.inspect()
end)
