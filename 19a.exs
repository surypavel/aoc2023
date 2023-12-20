{:ok, str} = File.read("19.txt")

defmodule AOC do
  def parse_rule_string(input) do
    [_, eq_str, next] =
      Regex.run(~r/(.+:)?(A|R|[a-z]+)/, input)

    eq =
      if eq_str != "" do
        Regex.run(~r/(x|m|a|s)(<|>)(\d+)/, eq_str)
        |> (fn [_, a, b, c] -> {a, b, String.to_integer(c)} end).()
      else
        nil
      end

    %{next: next, eq: eq}
  end

  def parse_workflow(input) do
    [_, name, rules_str] =
      Regex.run(~r/([a-z]+)\{(.+)\}/, input)

    rules = rules_str |> String.split(",") |> Enum.map(&AOC.parse_rule_string/1)
    %{name: name, rules: rules}
  end

  def parse_part(input) do
    [x, m, a, s] =
      Regex.scan(~r/\d+/, input) |> Enum.map(fn [match] -> String.to_integer(match) end)

    %{"x" => x, "m" => m, "a" => a, "s" => s}
  end

  def matches_eq(_part, nil), do: true
  def matches_eq(part, { var, op, num }) do
    value = Access.get(part, var)
    condition = if op == "<" do &Kernel.</2 else &Kernel.>/2 end
    condition.(value, num)
  end

  def is_accepted(workflows, workflow_name, part) do
    workflow = workflows |> Enum.find(fn wk -> wk.name == workflow_name end)
    matched_rule = workflow.rules |> Enum.find(nil, fn rule -> AOC.matches_eq(part, rule.eq) end)

    case matched_rule.next do
      "R" -> false
      "A" -> true
      _ -> AOC.is_accepted(workflows, matched_rule.next, part)
    end
  end
end

[workflows_str, parts_str] = String.split(str, "\n\n")
workflows = workflows_str |> String.split("\n") |> Enum.map(&AOC.parse_workflow/1)
parts = parts_str |> String.split("\n") |> Enum.map(&AOC.parse_part/1)
is_accepted = &AOC.is_accepted(workflows, "in", &1)

parts
|> Enum.filter(is_accepted)
|> Enum.map(fn part -> Map.values(part) |> Enum.sum() end)
|> Enum.sum()
|> IO.inspect()
