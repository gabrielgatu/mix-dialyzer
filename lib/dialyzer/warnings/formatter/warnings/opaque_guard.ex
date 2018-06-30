defmodule Dialyzer.Formatter.Warnings.OpaqueGuard do
  @behaviour Dialyzer.Formatter.Warning

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :opaque_guard
  def warning(), do: :opaque_guard

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Guard test breaks the opaqueness of its argument."
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([guard, args]) do
    "Guard test #{guard}#{args} breaks the opaqueness of its argument."
  end
end
