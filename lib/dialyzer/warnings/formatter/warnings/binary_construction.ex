# Credits: this code was originally part of the `dialyxir` project
# Copyright by Andrew Summers
# https://github.com/jeremyjh/dialyxir

defmodule Dialyzer.Formatter.Warnings.BinaryConstruction do
  @behaviour Dialyzer.Formatter.Warning

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :bin_construction
  def warning(), do: :bin_construction

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Binary construction will fail."
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([culprit, size, segment, type]) do
    pretty_type = Erlex.pretty_print_type(type)

    """
    Binary construction will fail since the #{culprit} field #{size} in
    segment #{segment} has type #{pretty_type}.
    """
  end
end
