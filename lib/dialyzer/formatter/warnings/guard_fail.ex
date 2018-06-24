defmodule Dialyzer.Warnings.GuardFail do
  @behaviour Dialyzer.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Warning
  @spec warning() :: :guard_fail
  def warning(), do: :guard_fail

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "pattern mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Guard test can never succeed because of a pattern mismatch."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([]) do
    "Guard test can never succeed because of a pattern mismatch."
  end

  def format_long([guard, args]) do
    pretty_args = Dialyzer.PrettyPrint.pretty_print_args(args)

    """
    #{color(:yellow, "Guard test:")}
    #{guard}#{pretty_args}

    can never succeed.
    """
  end

  def format_long([arg1, infix, arg2]) do
    pretty_arg1 = Dialyzer.PrettyPrint.pretty_print_type(arg1)
    pretty_arg2 = Dialyzer.PrettyPrint.pretty_print_args(arg2)
    pretty_infix = Dialyzer.PrettyPrint.pretty_print_infix(infix)

    """
    The function guard either presents an impossible guard or the only
    calls will never succeed against the guards.

    #{color(:yellow, "Guard test:")}
    #{pretty_arg1}

    #{pretty_infix}

    #{pretty_arg2}

    can never succeed.
    """
  end
end
