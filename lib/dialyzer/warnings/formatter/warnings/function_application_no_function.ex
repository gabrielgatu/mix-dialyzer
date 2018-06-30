defmodule Dialyzer.Formatter.Warnings.FunctionApplicationNoFunction do
  @behaviour Dialyzer.Formatter.Warning

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :fun_app_no_fun
  def warning(), do: :fun_app_no_fun

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "undefined function call"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Wrong number of arguments for function call."
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([op, type, arity]) do
    pretty_op = Dialyzer.Formatter.PrettyPrint.pretty_print(op)
    pretty_type = Dialyzer.Formatter.PrettyPrint.pretty_print_type(type)

    """
    The function being invoked exists has an arity mismatch.

    #{pretty_op} :: #{pretty_type} does not accept #{arity} arguments.
    """
  end
end
