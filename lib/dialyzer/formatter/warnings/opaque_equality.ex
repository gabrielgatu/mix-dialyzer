defmodule Dialyzer.Warnings.OpaqueEquality do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :opaque_eq
  def warning(), do: :opaque_eq

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Attempt to test for equality with an opaque type."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([type, _op, opaque_type]) do
    """
    Attempt to test for equality between a term of type #{type}
    and a term of opaque type #{opaque_type}.
    """
  end
end
