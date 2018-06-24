defmodule Dialyzer.Warnings.PatternMatchCovered do
  @behaviour Dialyzer.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Warning
  @spec warning() :: :pattern_match_cov
  def warning(), do: :pattern_match_cov

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "unreachable block"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "The pattern can never match the type since it covered by previous clauses."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([pattern, type]) do
    pretty_pattern = Dialyzer.PrettyPrint.pretty_print_pattern(pattern)
    pretty_type = Dialyzer.PrettyPrint.pretty_print_type(type)

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
