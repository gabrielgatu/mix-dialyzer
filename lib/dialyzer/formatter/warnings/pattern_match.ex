defmodule Dialyzer.Warnings.PatternMatch do
  @behaviour Dialyzer.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Warning
  @spec warning() :: :pattern_match
  def warning(), do: :pattern_match

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "pattern mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "The pattern can never match the type."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([pattern, type]) do
    pretty_pattern = Dialyzer.PrettyPrint.pretty_print_pattern(pattern)
    pretty_type = Dialyzer.PrettyPrint.pretty_print_type(type)

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
