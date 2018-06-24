defmodule Dialyzer.Warnings.ExactEquality do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :exact_eq
  def warning(), do: :exact_eq

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "value mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Expression can never evaluate to true."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([type1, op, type2]) do
    pretty_type1 = Dialyzer.PrettyPrint.pretty_print_type(type1)
    pretty_type2 = Dialyzer.PrettyPrint.pretty_print_type(type2)

    """
    The expression #{pretty_type1} #{op} #{pretty_type2} can never evaluate to 'true'.
    """
  end
end
