{:ok, str} = File.read("09.txt")

defmodule AOC do
  def load_numbers(input) do
    Regex.scan(~r/-?\d+/, input)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
  end

  def diff_sequences(seq) do
    Enum.zip([0 | seq], seq) |> Enum.map(fn {a, b} -> b - a end) |> Enum.drop(1)
  end

  def all_diff_sequences(seq) do
    next_sequence = diff_sequences(seq)

    if Enum.all?(next_sequence, fn el -> el == 0 end) do
      [[0 | next_sequence]]
    else
      all_diff_sequences(next_sequence) ++ [next_sequence]
    end
  end

  def backtrack([seq]) do
    Enum.at(seq, -1)
  end

  def backtrack([seq1, seq2 | rest]) do
    new = Enum.at(seq1, -1) + Enum.at(seq2, -1)
    backtrack([seq2 ++ [new] | rest])
  end

  def predict_sequence(str) do
    str
    |> AOC.load_numbers()
    |> (fn x -> AOC.all_diff_sequences(x) ++ [x] end).()
    |> AOC.backtrack()
  end
end

str |> String.split("\n") |> Enum.map(&AOC.predict_sequence/1) |> Enum.sum() |> IO.puts()
