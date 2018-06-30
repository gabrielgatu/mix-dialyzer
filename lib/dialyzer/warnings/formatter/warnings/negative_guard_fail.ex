defmodule Dialyzer.Formatter.Warnings.NegativeGuardFail do
  @behaviour Dialyzer.Formatter.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :neg_guard_fail
  def warning(), do: :neg_guard_fail

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "pattern mismatch"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Guard test can never succeed."
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([guard, args]) do
    pretty_args = Dialyzer.Formatter.PrettyPrint.pretty_print_args(args)

    """
    The function guard either presents an impossible guard or the only
    calls will never succeed against the guards.

    #{color(:yellow, "Guard test:")}
    not #{guard}#{pretty_args}

    can never succeed.
    """
  end

  def format_long([arg1, infix, arg2]) do
    pretty_infix = Dialyzer.Formatter.PrettyPrint.pretty_print_infix(infix)

    """
    The function guard either presents an impossible guard or the only
    calls will never succeed against the guards.

    #{color(:yellow, "Guard test:")}
    not #{arg1} #{pretty_infix} #{arg2}

    can never succeed.
    """
  end
end
