defmodule Dialyzer.Warnings.RaceCondition do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :race_condition
  def warning(), do: :race_condition

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "race condition"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(args), do: format_long(args)

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([module, function, args, reason]) do
    pretty_args = Dialyzer.PrettyPrint.pretty_print_args(args)
    pretty_module = Dialyzer.PrettyPrint.pretty_print(module)

    "The call #{pretty_module},#{function}#{pretty_args} #{reason}."
  end
end
