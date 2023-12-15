{:ok, str} = File.read("12.txt")

defmodule Math do
  def factorial(0), do: 1

  def factorial(n) when n > 0 do
    n * factorial(n - 1)
  end

  def comb(n, k) do
    div(Math.factorial(n), Math.factorial(k) * Math.factorial(n - k))
  end
end

defmodule Combinations do
  @doc """
  This function lists all combinations of `num` elements from the given `list`
  """
  def product(list, num)
  def product(list, 1), do: Enum.map(list, fn item -> [item] end)
  def product(list = [], _num), do: list

  def product(list, num) do
    for i <- Combinations.product(list, num - 1), j <- list, do: [j | i]
  end

  def combinations(list, num)
  def combinations(_list, 0), do: [[]]
  def combinations(list = [], _num), do: list

  def combinations([head | tail], num) do
    Enum.map(combinations(tail, num - 1), &[head | &1]) ++
      combinations(tail, num)
  end
end

defmodule AOC do
  def parse_line(str) do
    [records_1, checksum_1] = String.split(str, " ")
    records = 1..2 |> Enum.map(fn _ -> records_1 end) |> Enum.join("?")
    checksum = 1..2 |> Enum.map(fn _ -> checksum_1 end) |> Enum.join(",")

    {
      records,
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

  def _calc_possibilities({"?" <> tail, instructions}) do
    str = "?" <> tail
    g = String.graphemes(str)

    if AOC.makes_sense(instructions, g) do
      freq = Enum.frequencies(g)

      if 2 * Map.get(freq, "?", 0) >= Map.get(freq, "#", 0) do
        AOC._calc_possibilities_a({str, instructions})
      else
        AOC._calc_possibilities_b({str, instructions})
      end
    else
      0
    end
  end

  def _calc_possibilities_a({str, instructions}) do
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

  def _calc_possibilities_b({"?" <> tail, checksum}) do
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

  def get_splits(i2, comb) do
    comb
    |> Enum.map_reduce(0, fn comb1, acc ->
      {i2 |> Enum.drop(acc) |> Enum.take(comb1), acc + comb1}
    end)
    |> elem(0)
  end

  def valid_splits(i1, i2) do
    stream_len = Enum.count(i1)
    instruction_len = Enum.count(i2)

    Combinations.product(0..1 |> Enum.to_list(), stream_len)
    |> Enum.filter(fn comb -> Enum.sum(comb) == instruction_len end)
    |> Enum.filter(fn comb ->
      i2
      |> AOC.get_splits(comb)
      |> Enum.map(fn t -> Enum.sum(t) + Enum.count(t) - 1 end)
      |> Enum.zip(i1)
      |> Enum.all?(fn {t, i1_item} -> t <= i1_item end)
    end)
  end

  def calc_comb(split, i1) do
    space = Enum.count(split) + Enum.sum(split) - 1
    diff = i1 - space
    n = Enum.count(split) + diff
    k = diff

    if diff >= 0 do
      Math.comb(n, k)
    else
      0
    end
  end

  def elementary_combinations(i1, i2) do
    AOC.valid_splits(i1, i2)
    |> Enum.map(fn split ->
      AOC.get_splits(i2, split)
      |> Enum.zip(i1)
      |> Enum.map(fn {split, i1} -> AOC.calc_comb(split, i1) end)
      |> Enum.product()
    end)
    |> Enum.sum()
  end

  def composite_combinations(str, instructions) do
    sharps =
      str
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.filter(fn {val, _} -> val == "#" end)
      |> Enum.map(fn {_, i} -> i end)

    all_q = str |> String.replace("#", "?")

    all =
      all_q
      |> String.split(".")
      |> Enum.filter(fn item -> item != "" end)
      |> Enum.map(fn item -> String.length(item) end)

    array =
      0..(Enum.count(sharps))
      |> Enum.map(fn c ->
        sharps
        |> Combinations.combinations(c)
        |> Enum.map(fn combination ->
          Enum.reduce(combination, String.graphemes(all_q), fn curr, acc ->
            List.replace_at(acc, curr, ".")
          end)
          |> Enum.join()
          |> String.split(".")
          |> Enum.filter(fn item -> item != "" end)
          |> Enum.map(fn item -> String.length(item) end)
          |> AOC.elementary_combinations(instructions)
        end)
        |> Enum.sum()
      end)
      |> (&[0 | &1]).()
      |> Enum.map_every(2, fn x -> -x end)
      |> Enum.sum()
  end
end

str
|> String.split("\n")
|> Enum.map(fn line ->
  line |> AOC.parse_line() |> (fn {x, y} -> AOC.composite_combinations(x,y) end).() |> IO.inspect()
end)
