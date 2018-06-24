defmodule Dialyzer.Warnings.FuncionApplicationArguments do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :fun_app_args
  def warning(), do: :fun_app_args

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Wrong types for function call."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([args, type]) do
    pretty_args = Dialyzer.PrettyPrint.pretty_print_args(args)
    pretty_type = Dialyzer.PrettyPrint.pretty_print(type)

    "Function call with arguments #{pretty_args} will fail " <>
      "since the function has type #{pretty_type}."
  end
end
