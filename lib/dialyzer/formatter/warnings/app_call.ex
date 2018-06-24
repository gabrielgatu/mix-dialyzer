defmodule Dialyzer.Warnings.AppCall do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :app_call
  def warning(), do: :app_call

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short([module, function, arity, _culprit, _expected_type, _actual_type]) do
    pretty_module = Dialyzer.PrettyPrint.pretty_print(module)

    "The call #{pretty_module}.#{function}/#{arity} has a type mismatch."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([module, function, arity, culprit, expected_type, actual_type]) do
    pretty_module = Dialyzer.PrettyPrint.pretty_print(module)
    pretty_expected_type = Dialyzer.PrettyPrint.pretty_print_type(expected_type)
    pretty_actual_type = Dialyzer.PrettyPrint.pretty_print_type(actual_type)

    """
    The call #{pretty_module}.#{function}/#{arity} requires that
    #{culprit} is of type #{pretty_expected_type} not #{pretty_actual_type}
    """
  end
end
