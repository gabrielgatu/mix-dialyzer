# Credits: this code was originally part of the `dialyxir` project
# Copyright by Andrew Summers
# https://github.com/jeremyjh/dialyxir

defmodule Dialyzer.Formatter.Warnings.UnknownFunction do
  @behaviour Dialyzer.Formatter.Warning

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :unknown_function
  def warning(), do: :unknown_function

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "undefined function"

  @impl Dialyzer.Formatter.Warning
  @spec format_short({String.t(), String.t(), String.t()}) :: String.t()
  def format_short(args), do: format_long(args)

  @impl Dialyzer.Formatter.Warning
  @spec format_long({String.t(), String.t(), String.t()}) :: String.t()
  def format_long({module, function, arity}) do
    pretty_module = Dialyzer.Formatter.PrettyPrint.pretty_print(module)
    "Function #{pretty_module}.#{function}/#{arity} does not exist."
  end
end
