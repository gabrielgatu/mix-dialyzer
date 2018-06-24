defmodule Dialyzer.Warnings.BinaryConstruction do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :bin_construction
  def warning(), do: :bin_construction

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Binary construction will fail."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([culprit, size, segment, type]) do
    pretty_type = Dialyzer.PrettyPrint.pretty_print_type(type)

    """
    Binary construction will fail since the #{culprit} field #{size} in
    segment #{segment} has type #{pretty_type}.
    """
  end
end
