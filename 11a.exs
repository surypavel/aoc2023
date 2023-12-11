{:ok, str} = File.read("11.txt")

defmodule AOC do
  def find_stars(input) do
    input
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      String.graphemes(row)
      |> Enum.with_index()
      |> Enum.flat_map(fn {char, x} ->
        if char == "#" do
          [{x, y}]
        else
          []
        end
      end)
    end)
  end

  def get_expansion(stars) do
    x = stars |> Enum.map(&elem(&1, 0)) |> Enum.uniq() |> Enum.sort()
    y = stars |> Enum.map(&elem(&1, 1)) |> Enum.uniq() |> Enum.sort()
    {x, y}
  end

  def distance2d(a, b, e) do
    max = max(a, b)
    min = min(a, b)

    stars_len =
      Enum.filter(e, fn item -> item > min and item < max end) |> Enum.count()

    max(0, (2 * (max - min - 1) - stars_len + 1))
  end

  def distance({x1, y1}, {x2, y2}, {ex, ey}) do
    AOC.distance2d(x1, x2, ex) + distance2d(y1, y2, ey)
  end
end

stars = AOC.find_stars(str)
expansion = AOC.get_expansion(stars)
star_pairs = for s1 <- stars, s2 <- stars, s1 < s2, do: {s1, s2}

star_pairs
|> Enum.map(fn {s1, s2} -> AOC.distance(s1, s2, expansion) end)
|> Enum.sum()
|> IO.puts()
