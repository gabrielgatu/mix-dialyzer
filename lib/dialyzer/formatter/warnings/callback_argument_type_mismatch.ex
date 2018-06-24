defmodule Dialyzer.Warnings.CallbackArgumentTypeMismatch do
  @behaviour Dialyzer.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Warning
  @spec warning() :: :callback_arg_type_mismatch
  def warning(), do: :callback_arg_type_mismatch

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short([behaviour, function, arity, position, _success_type, _callback_type]) do
    pretty_behaviour = Dialyzer.PrettyPrint.pretty_print(behaviour)
    ordinal_position = Dialyzer.WarningHelpers.ordinal(position)

    "Type mismatch in #{ordinal_position} argument for #{function}/#{arity}" <>
      " callback in #{pretty_behaviour} behaviour."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([behaviour, function, arity, position, success_type, callback_type]) do
    pretty_behaviour = Dialyzer.PrettyPrint.pretty_print(behaviour)
    pretty_success_type = Dialyzer.PrettyPrint.pretty_print_type(success_type)
    pretty_callback_type = Dialyzer.PrettyPrint.pretty_print_type(callback_type)
    ordinal_position = Dialyzer.WarningHelpers.ordinal(position)

    """
    The inferred type for the #{ordinal_position} argument is not a
    supertype of the expected type for the #{function}/#{arity} callback
    in the #{pretty_behaviour} behaviour.

    #{color(:yellow, "Success type:")}
    #{pretty_success_type}

    #{color(:yellow, "Behaviour callback type:")}
    #{pretty_callback_type}
    """
  end
end
