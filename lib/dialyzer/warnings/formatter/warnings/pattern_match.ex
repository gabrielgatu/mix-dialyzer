defmodule Dialyzer.Formatter.Warnings.PatternMatch do
  @behaviour Dialyzer.Formatter.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :pattern_match
  def warning(), do: :pattern_match

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "pattern mismatch"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "The pattern can never match the type."
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([pattern, type]) do
    pretty_pattern = Dialyzer.Formatter.PrettyPrint.pretty_print_pattern(pattern)
    pretty_type = Dialyzer.Formatter.PrettyPrint.pretty_print_type(type)

    """
    The pattern matching is never given a value that satisfies all of
    its clauses.

    #{color(:yellow, "The pattern")}
    #{pretty_pattern}

    #{color(:yellow, "can never match the type")}
    #{pretty_type}
    """
  end
end
