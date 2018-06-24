defmodule Dialyzer.Warnings.UnknownFunction do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :unknown_function
  def warning(), do: :unknown_function

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "undefined function"

  @impl Dialyzer.Warning
  @spec format_short({String.t(), String.t(), String.t()}) :: String.t()
  def format_short(args), do: format_long(args)

  @impl Dialyzer.Warning
  @spec format_long({String.t(), String.t(), String.t()}) :: String.t()
  def format_long({module, function, arity}) do
    pretty_module = Dialyzer.PrettyPrint.pretty_print(module)
    "Function #{pretty_module}.#{function}/#{arity} does not exist."
  end
end
