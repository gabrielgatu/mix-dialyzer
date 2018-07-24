# Credits: this code was originally part of the `dialyxir` project
# Copyright by Andrew Summers
# https://github.com/jeremyjh/dialyxir

defmodule Dialyzer.Formatter.Warnings.RaceCondition do
  @behaviour Dialyzer.Formatter.Warning

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :race_condition
  def warning(), do: :race_condition

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "race condition"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(args), do: format_long(args)

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([module, function, args, reason]) do
    pretty_args = Erlex.pretty_print_args(args)
    pretty_module = Erlex.pretty_print(module)

    "The call #{pretty_module},#{function}#{pretty_args} #{reason}."
  end
end
