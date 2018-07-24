# Credits: this code was originally part of the `dialyxir` project
# Copyright by Andrew Summers
# https://github.com/jeremyjh/dialyxir

defmodule Dialyzer.Formatter.Warnings.AppCall do
  @behaviour Dialyzer.Formatter.Warning

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :app_call
  def warning(), do: :app_call

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short([module, function, arity, _culprit, _expected_type, _actual_type]) do
    pretty_module = Erlex.pretty_print(module)

    "The call #{pretty_module}.#{function}/#{arity} has a type mismatch."
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([module, function, arity, culprit, expected_type, actual_type]) do
    pretty_module = Erlex.pretty_print(module)
    pretty_expected_type = Erlex.pretty_print_type(expected_type)
    pretty_actual_type = Erlex.pretty_print_type(actual_type)

    """
    The call #{pretty_module}.#{function}/#{arity} requires that
    #{culprit} is of type #{pretty_expected_type} not #{pretty_actual_type}
    """
  end
end
