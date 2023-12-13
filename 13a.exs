{:ok, str} = File.read("13.txt")

defmodule AOC do
  def load_input(str) do
    rows = str |> String.split("\n")

    columns =
      rows
      |> Enum.map(&String.graphemes/1)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(&Enum.join/1)

    {rows, columns}
  end

  def reflects?(string, index) do
    {a, b} = String.split_at(string, index)
    ra = String.reverse(a)
    String.starts_with?(ra, b) or String.starts_with?(b, ra)
  end

  def find_reflection(items, transposed) do
    len = Enum.count(transposed)
    init_range = 1..(len - 1) |> Enum.to_list()

    refl =
      items
      |> Enum.reduce_while(init_range, fn item, range ->
        new_range = range |> Enum.filter(&AOC.reflects?(item, &1))

        {if Enum.count(new_range) == 0 do
           :halt
         else
           :cont
         end, new_range}
      end)

    if Enum.count(refl) == 0 do
      0
    else
      [first] = refl
      first
    end
  end

  def calc_reflection({rows, columns}) do
    r = find_reflection(rows, columns)
    c = find_reflection(columns, rows)
    100 * c + r
  end
end

str
|> String.split("\n\n")
|> Enum.map(fn input -> AOC.load_input(input) |> AOC.calc_reflection() end)
|> IO.inspect()
|> Enum.sum()
|> IO.inspect()
