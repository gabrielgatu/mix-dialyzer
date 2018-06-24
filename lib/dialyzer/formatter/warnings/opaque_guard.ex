defmodule Dialyzer.Warnings.OpaqueGuard do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :opaque_guard
  def warning(), do: :opaque_guard

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Guard test breaks the opaqueness of its argument."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([guard, args]) do
    "Guard test #{guard}#{args} breaks the opaqueness of its argument."
  end
end
