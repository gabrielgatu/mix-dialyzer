# Credits: this code was originally part of the `dialyxir` project
# Copyright by Andrew Summers
# https://github.com/jeremyjh/dialyxir

defmodule Dialyzer.Formatter.Warnings.UnknownType do
  @behaviour Dialyzer.Formatter.Warning

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :unknown_type
  def warning(), do: :unknown_type

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "spec mismatch"

  @impl Dialyzer.Formatter.Warning
  @spec format_short({String.t(), String.t(), String.t()}) :: String.t()
  def format_short(args), do: format_long(args)

  @impl Dialyzer.Formatter.Warning
  @spec format_long({String.t(), String.t(), String.t()}) :: String.t()
  def format_long({module, function, arity}) do
    pretty_module = Erlex.pretty_print(module)

    "Spec references a missing @type: #{pretty_module}.#{function}/#{arity}."
  end
end
