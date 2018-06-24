defmodule Dialyzer.Warnings.OpaqueTypeTest do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :opaque_type_test
  def warning(), do: :opaque_type_test

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "The type test breaks the opaqueness of the term."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([function, opaque]) do
    "The type test #{function}(#{opaque}) breaks the opaqueness of the term #{opaque}."
  end
end
