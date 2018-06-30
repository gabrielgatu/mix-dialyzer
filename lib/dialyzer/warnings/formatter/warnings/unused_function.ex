defmodule Dialyzer.Formatter.Warnings.UnusedFunction do
  @behaviour Dialyzer.Formatter.Warning

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :unused_fun
  def warning(), do: :unused_fun

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "unreachable block"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short([function, arity]) do
    "Function #{function}/#{arity} will never be called."
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([function, arity]) do
    """
    Due to issues higher in the function or call stack, while the
    function is recognized as used by the compiler, it will never be
    recognized as having been called until the other error is
    resolved.

    Function #{function}/#{arity} will never be called.
    """
  end
end
