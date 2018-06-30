defmodule Dialyzer.Formatter.Warnings.CallbackTypeMismatch do
  @behaviour Dialyzer.Formatter.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :callback_type_mismatch
  def warning(), do: :callback_type_mismatch

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "callback mismatch"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short([behaviour, function, arity, _fail_type, _success_type]) do
    pretty_behaviour = Dialyzer.Formatter.PrettyPrint.pretty_print(behaviour)
    "Callback mismatch for @callback #{function}/#{arity} in #{pretty_behaviour} behaviour."
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t() | non_neg_integer]) :: String.t()
  def format_long([behaviour, function, arity, fail_type, success_type]) do
    pretty_behaviour = Dialyzer.Formatter.PrettyPrint.pretty_print(behaviour)
    pretty_fail_type = Dialyzer.Formatter.PrettyPrint.pretty_print_type(fail_type)
    pretty_success_type = Dialyzer.Formatter.PrettyPrint.pretty_print_type(success_type)

    """
    The success type of the function does not match the callback type
    in behaviour: #{function}/#{arity} in #{pretty_behaviour}

    #{color(:yellow, "Actual:")}
    #{pretty_fail_type}

    #{color(:yellow, "Expected:")}
    #{pretty_success_type}
    """
  end
end
