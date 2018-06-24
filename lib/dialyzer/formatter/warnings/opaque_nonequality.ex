defmodule Dialyzer.Warnings.OpaqueNonequality do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :opaque_neq
  def warning(), do: :opaque_neq

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Attempted to test for inequality between a type and an opaque type."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([type, _op, opaque_type]) do
    """
    Attempt to test for inequality between a term of type #{type}
    and a term of opaque type #{opaque_type}.
    """
  end
end
