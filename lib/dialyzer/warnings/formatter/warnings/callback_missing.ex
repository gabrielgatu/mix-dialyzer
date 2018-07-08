# Credits: this code was originally part of the `dialyxir` project
# Copyright by Andrew Summers
# https://github.com/jeremyjh/dialyxir

defmodule Dialyzer.Formatter.Warnings.CallbackMissing do
  @behaviour Dialyzer.Formatter.Warning

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :callback_missing
  def warning(), do: :callback_missing

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "undefined callback"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short([behaviour, function, arity]) do
    pretty_behaviour = Dialyzer.Formatter.PrettyPrint.pretty_print(behaviour)

    "Undefined callback function #{function}/#{arity} (behaviour #{pretty_behaviour})."
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([behaviour, function, arity]) do
    pretty_behaviour = Dialyzer.Formatter.PrettyPrint.pretty_print(behaviour)

    """
    Module implements a behaviour but does not have all of its
    callbacks.

    #{function}/#{arity} (behaviour #{pretty_behaviour})
    """
  end
end
