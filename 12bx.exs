{:ok, str} = File.read("12.txt")

defmodule AOC do
  def parse_line(str) do
    [records_1, checksum_1] = String.split(str, " ")
    records = 1..5 |> Enum.map(fn _ -> records_1 end) |> Enum.join("?")
    checksum = 1..5 |> Enum.map(fn _ -> checksum_1 end) |> Enum.join(",")
    {records, String.split(checksum, ",") |> Enum.map(&String.to_integer/1)}
  end

  def is_possible(records, checksum) do
    delim = "[?.]"
    regex_groups = checksum |> Enum.map(fn num -> "[?#]{#{num}}" end) |> Enum.join("(#{delim}+?)")
    regex_str = "^(#{delim}*?)#{regex_groups}(#{delim}*?)$"
    {:ok, regex} = Regex.compile(regex_str)
    IO.inspect(Regex.run(regex, records) |> Enum.drop(1))
    Regex.match?(regex, records)
  end

  def calc_possibilities({records, []}) do
    if String.contains?(records, "#") do
      0
    else
      1
    end
  end

  def calc_possibilities({records, checksum = [head | tail]}) do
    if !is_possible(records, checksum) do
      0
    else
      0..(String.length(records) - head)
      |> Enum.map(fn index ->
        s1 = String.slice(records, 0, index)
        s2 = String.slice(records, index, head)
        s3 = String.slice(records, index + head, 1)
        s4 = String.slice(records, (index + head + 1)..-1)
        bad_start = s1 |> String.contains?("#")
        bad_match = s2 |> String.contains?(".")
        no_space = s3 |> String.contains?("#")

        if !bad_start and !bad_match and !no_space do
          calc_possibilities({s4, tail})
        else
          0
        end
      end)
      |> Enum.sum()
    end
  end
end

str
|> String.split("\n")
|> Enum.map(&AOC.parse_line/1)
|> Enum.map(fn { r, c } -> AOC.is_possible(r, c) |> IO.inspect() end)
# |> Enum.map(fn line -> AOC.calc_possibilities(line) |> IO.inspect() end)
|> Enum.sum()
|> IO.inspect()
