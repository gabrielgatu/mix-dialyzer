defmodule Dialyzer.Warnings.CallbackSpecTypeMismatch do
  @behaviour Dialyzer.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Warning
  @spec warning() :: :callback_spec_type_mismatch
  def warning(), do: :callback_spec_type_mismatch

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "spec mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short([behaviour, function, arity, _success_type, _callback_type]) do
    pretty_behaviour = Dialyzer.PrettyPrint.pretty_print(behaviour)

    "The @spec return type for does not match the expected return type" <>
      "for #{function}/#{arity} callback in #{pretty_behaviour} behaviour."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([behaviour, function, arity, success_type, callback_type]) do
    pretty_behaviour = Dialyzer.PrettyPrint.pretty_print(behaviour)
    pretty_success_type = Dialyzer.PrettyPrint.pretty_print_type(success_type)
    pretty_callback_type = Dialyzer.PrettyPrint.pretty_print_type(callback_type)

    """
    The @spec return type for does not match the expected return type
    for #{function}/#{arity} callback  in #{pretty_behaviour} behaviour.

    #{color(:yellow, "Actual:")}
    @spec #{function}(...) :: #{pretty_success_type}

    #{color(:yellow, "Expected:")}
    @spec #{function}(...) :: #{pretty_callback_type}
    """
  end
end
