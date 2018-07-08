# Credits: this code was originally part of the `dialyxir` project
# Copyright by Andrew Summers
# https://github.com/jeremyjh/dialyxir

defmodule Dialyzer.Formatter.Warnings.UnknownBehaviour do
  @behaviour Dialyzer.Formatter.Warning

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :unknown_behaviour
  def warning(), do: :unknown_behaviour

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "undefined behaviour"

  @impl Dialyzer.Formatter.Warning
  @spec format_short(String.t()) :: String.t()
  def format_short(args), do: format_long(args)

  @impl Dialyzer.Formatter.Warning
  @spec format_long(String.t()) :: String.t()
  def format_long(behaviour) do
    pretty_module = Dialyzer.Formatter.PrettyPrint.pretty_print(behaviour)

    "Unknown behaviour: #{pretty_module}."
  end
end
