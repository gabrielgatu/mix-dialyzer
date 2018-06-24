defmodule Dialyzer.Warnings.UnknownType do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :unknown_type
  def warning(), do: :unknown_type

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "spec mismatch"

  @impl Dialyzer.Warning
  @spec format_short({String.t(), String.t(), String.t()}) :: String.t()
  def format_short(args), do: format_long(args)

  @impl Dialyzer.Warning
  @spec format_long({String.t(), String.t(), String.t()}) :: String.t()
  def format_long({module, function, arity}) do
    pretty_module = Dialyzer.PrettyPrint.pretty_print(module)

    "Spec references a missing @type: #{pretty_module}.#{function}/#{arity}."
  end
end
