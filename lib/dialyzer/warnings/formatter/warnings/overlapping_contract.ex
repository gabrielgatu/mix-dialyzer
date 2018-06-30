defmodule Dialyzer.Formatter.Warnings.OverlappingContract do
  @behaviour Dialyzer.Formatter.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :overlapping_contract
  def warning(), do: :overlapping_contract

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "unreachable block"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short([module, function, arity]) do
    pretty_module = Dialyzer.Formatter.PrettyPrint.pretty_print(module)

    "Overloaded contract for #{pretty_module}.#{function}/#{arity}"
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([module, function, arity]) do
    pretty_module = Dialyzer.Formatter.PrettyPrint.pretty_print(module)

    """
    The function has an additional @spec that is already covered more
    generally by a higher @spec.

    #{color(:yellow, "Actual:")}
    #{pretty_module}.#{function}/#{arity}
    """
  end
end
