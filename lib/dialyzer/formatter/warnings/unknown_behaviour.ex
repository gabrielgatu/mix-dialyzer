defmodule Dialyzer.Warnings.UnknownBehaviour do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :unknown_behaviour
  def warning(), do: :unknown_behaviour

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "undefined behaviour"

  @impl Dialyzer.Warning
  @spec format_short(String.t()) :: String.t()
  def format_short(args), do: format_long(args)

  @impl Dialyzer.Warning
  @spec format_long(String.t()) :: String.t()
  def format_long(behaviour) do
    pretty_module = Dialyzer.PrettyPrint.pretty_print(behaviour)

    "Unknown behaviour: #{pretty_module}."
  end
end
