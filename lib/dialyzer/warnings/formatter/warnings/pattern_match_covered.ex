# Credits: this code was originally part of the `dialyxir` project
# Copyright by Andrew Summers
# https://github.com/jeremyjh/dialyxir

defmodule Dialyzer.Formatter.Warnings.PatternMatchCovered do
  @behaviour Dialyzer.Formatter.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :pattern_match_cov
  def warning(), do: :pattern_match_cov

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "unreachable block"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "The pattern can never match the type since it covered by previous clauses."
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([pattern, type]) do
    pretty_pattern = Dialyzer.Formatter.PrettyPrint.pretty_print_pattern(pattern)
    pretty_type = Dialyzer.Formatter.PrettyPrint.pretty_print_type(type)

    """
    The pattern match has a later clause that will never be executed
    because a more general clause is higher in the matching order.

    #{color(:yellow, "Unreachable pattern:")}
    #{pretty_pattern}

    #{color(:yellow, "Because covered by:")}
    #{pretty_type}
    """
  end
end
