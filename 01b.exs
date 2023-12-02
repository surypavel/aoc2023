{:ok, str} = File.read("01.txt")

defmodule AOC do
  def find_number(parameter1) do
    numbersMap = %{
      "zero" => "0",
      "one" => "1",
      "two" => "2",
      "three" => "3",
      "four" => "4",
      "five" => "5",
      "six" => "6",
      "seven" => "7",
      "eight" => "8",
      "nine" => "9"
    }

    result = numbersMap
      |> Map.keys()
      |> Enum.join("|")
      |> (&"(?=(#{&1}|\\d))").()
      |> Regex.compile!()
      |> Regex.scan(parameter1)
      |> Enum.map(&Enum.at(&1, 1))
      |> Enum.map(&Map.get(numbersMap, &1, &1))

    (Enum.at(result, 0) <> Enum.at(result, -1))
      |> Integer.parse
      |> elem(0)
  end
end

result =
  str
  |> String.split("\n")
  |> Enum.map(&AOC.find_number(&1))
  |> Enum.sum()

IO.puts(result)
