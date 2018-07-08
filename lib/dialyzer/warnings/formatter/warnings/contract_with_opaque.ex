# Credits: this code was originally part of the `dialyxir` project
# Copyright by Andrew Summers
# https://github.com/jeremyjh/dialyxir

defmodule Dialyzer.Formatter.Warnings.ContractWithOpaque do
  @behaviour Dialyzer.Formatter.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :contract_with_opaque
  def warning(), do: :contract_with_opaque

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "The @spec has an opaque subtype which is violated by the success typing"
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([module, function, arity, type, signature_type]) do
    pretty_module = Dialyzer.Formatter.PrettyPrint.pretty_print(module)
    pretty_type = Dialyzer.Formatter.PrettyPrint.pretty_print_type(type)
    pretty_success_type = Dialyzer.Formatter.PrettyPrint.pretty_print_type(signature_type)

    """
    The @spec says the function is returning an opaque type but it is
    returning a different type.

    #{color(:yellow, "Type specification:")}
    #{pretty_module}.#{function}/#{arity} declared this opaque type: #{pretty_type}

    #{color(:yellow, "Success typing:")}
    #{pretty_success_type}
    """
  end
end
