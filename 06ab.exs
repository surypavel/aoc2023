{:ok, str} = File.read("06.txt")

defmodule AOC do
  def load_numbers(input) do
    Regex.scan(~r/\d+/, input)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
  end

  def zip_numbers([row1, row2]) do
    Enum.zip(row1, row2)
  end

  def calc_solutions({t, r}) do
    # (t - x) * x > r
    # x^2 - tx + r < 0
    # D = t2 - 4r
    d = t * t - 4 * r
    x1 = (t - d ** 0.5) / 2
    x2 = (t + d ** 0.5) / 2
    { x1, x2 }
  end

  def interval_length(setup) do
    {x1, x2} = AOC.calc_solutions(setup)
    trunc(Float.ceil(x2) - Float.floor(x1) - 1)
  end
end

rounds =
  str
  |> String.split("\n")
  |> Enum.map(&String.replace(&1, " ", "")) # for part 2
  |> Enum.map(&AOC.load_numbers/1)
  |> AOC.zip_numbers()
  |> Enum.map(&AOC.interval_length/1)
  |> Enum.product()

IO.puts(rounds)
