defmodule Dialyzer.Warnings.CallbackMissing do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :callback_missing
  def warning(), do: :callback_missing

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "undefined callback"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short([behaviour, function, arity]) do
    pretty_behaviour = Dialyzer.PrettyPrint.pretty_print(behaviour)

    "Undefined callback function #{function}/#{arity} (behaviour #{pretty_behaviour})."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([behaviour, function, arity]) do
    pretty_behaviour = Dialyzer.PrettyPrint.pretty_print(behaviour)

    """
    Module implements a behaviour but does not have all of its
    callbacks.

    #{function}/#{arity} (behaviour #{pretty_behaviour})
    """
  end
end
