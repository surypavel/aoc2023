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

    rules = rules_str |> String.split(",") |> Enum.map(&parse_rule_string/1)
    %{name: name, rules: rules}
  end

  def parse_part(input) do
    [x, m, a, s] =
      Regex.scan(~r/\d+/, input) |> Enum.map(fn [match] -> String.to_integer(match) end)

    %{"x" => x, "m" => m, "a" => a, "s" => s}
  end

  def matches_eq(_part, nil), do: true

  def matches_eq(part, {var, op, num}) do
    value = Access.get(part, var)

    condition =
      if op == "<" do
        &Kernel.</2
      else
        &Kernel.>/2
      end

    condition.(value, num)
  end

  def count_paths(rules, implicit_rules) do
    rules
    |> Enum.reduce([], fn rule, acc ->
      last = Enum.at(acc, 0)

      new_eqs =
        if last == nil do
          [rule.eq | implicit_rules]
        else
          %{eqs: prev_eqs} = last
          {invert, keep} = prev_eqs |> Enum.split(1)

          modified_eqs =
            invert
            |> Enum.map(fn {var, op, num} ->
              case op do
                ">" -> {var, "<", num + 1}
                "<" -> {var, ">", num - 1}
              end
            end)

          ([rule.eq | modified_eqs] ++ keep)
          |> Enum.filter(fn rule -> rule != nil end)
        end

      [%{next: rule.next, eqs: new_eqs} | acc]
    end)
  end

  def get_accepted(workflows, workflow_name, implicit_rules) do
    workflow = workflows |> Enum.find(fn wk -> wk.name == workflow_name end)

    count_paths(workflow.rules, implicit_rules)
    |> Enum.flat_map(fn path ->
      case path.next do
        "R" -> []
        "A" -> [path.eqs]
        _ -> get_accepted(workflows, path.next, path.eqs)
      end
    end)
  end

  def find_interval(eqs) do
    min =
      eqs
      |> Enum.filter(fn {_, op, _} ->
        op == ">"
      end)
      |> Enum.map(fn {_, _, val} -> val end)
      |> Enum.max(fn -> 0 end)
      |> (fn x -> x + 1 end).()

    max =
      eqs
      |> Enum.filter(fn {_, op, _} ->
        op == "<"
      end)
      |> Enum.map(fn {_, _, val} -> val end)
      |> Enum.min(fn -> 4001 end)

    {min, max}
  end

  def find_rule_breakpoints(eqs) do
    eqs
    |> Enum.group_by(&elem(&1, 0))
    |> Enum.map(fn {_var, eqs} -> find_interval(eqs) end)
  end

  def count_accepted(workflows) do
    accepted = get_accepted(workflows, "in", [])

    accepted
    |> Enum.map(fn eqs ->
      interval_sizes =
        eqs
        |> find_rule_breakpoints()
        |> Enum.map(fn {a, b} -> b - a end)
        |> Enum.filter(fn diff -> diff > 0 end)

      Enum.product(interval_sizes) * 4000 ** (4 - Enum.count(interval_sizes))
    end)
    |> Enum.sum()
  end
end

[workflows_str, _parts_str] = String.split(str, "\n\n")
workflows = workflows_str |> String.split("\n") |> Enum.map(&AOC.parse_workflow/1)
AOC.count_accepted(workflows) |> IO.inspect()
