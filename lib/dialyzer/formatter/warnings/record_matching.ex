defmodule Dialyzer.Warnings.RecordMatching do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :record_matching
  def warning(), do: :record_matching

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(args), do: format_long(args)

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([string, name]) do
    "The #{string} violates the declared type for ##{name}{}."
  end
end
