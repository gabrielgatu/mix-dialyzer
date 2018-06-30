defmodule Dialyzer.Formatter.Warnings.UnmatchedReturn do
  @behaviour Dialyzer.Formatter.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :unmatched_return
  def warning(), do: :unmatched_return

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "pattern mismatch"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Expression produces multiple types but none are matched."
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([type]) do
    pretty_type = Dialyzer.Formatter.PrettyPrint.pretty_print_type(type)

    """
    The invoked expression returns a union of types and the call does
    not match on its return types using e.g. a case or wildcard.

    #{color(:yellow, "Value produced:")}
    #{pretty_type}

    but this value is unmatched.
    """
  end
end
