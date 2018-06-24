defmodule Dialyzer.Warnings.GuardFailPattern do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :guard_fail_pat
  def warning(), do: :guard_fail_pat

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "pattern mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Clause guard cannot succeed because of a pattern mismatch."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([pattern, type]) do
    pretty_type = Dialyzer.PrettyPrint.pretty_print_type(type)
    pretty_pattern = Dialyzer.PrettyPrint.pretty_print_pattern(pattern)

    """
    The guard describes a condition of literals that fails the pattern
    given in function head.

    The pattern #{pretty_pattern} was matched against the type #{pretty_type}
    """
  end
end
