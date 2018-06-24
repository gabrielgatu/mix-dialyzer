defmodule Dialyzer.Warnings.UnusedFunction do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :unused_fun
  def warning(), do: :unused_fun

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "unreachable block"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short([function, arity]) do
    "Function #{function}/#{arity} will never be called."
  end

  @impl Dialyzer.Warning
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
