defmodule Dialyzer.Formatter.Warnings.RecordConstruction do
  @behaviour Dialyzer.Formatter.Warning

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :record_constr
  def warning(), do: :record_constr

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Record construction violates the declared type."
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([types, name]) do
    "Record construction #{types} violates the declared type for ##{name}{}."
  end

  def format_long([name, field, type]) do
    """
    Record construction violates the declared type for ##{name}{} since
    #{field} cannot be of type #{type}.
    """
  end
end
