defmodule Dialyzer.Warnings.InvalidContract do
  @behaviour Dialyzer.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Warning
  @spec warning() :: :invalid_contract
  def warning(), do: :invalid_contract

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short([module, function, arity, _signature]) do
    pretty_module = Dialyzer.PrettyPrint.pretty_print(module)

    "Invalid type specification for function #{pretty_module}.#{function}/#{arity}."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([module, function, arity, signature]) do
    pretty_module = Dialyzer.PrettyPrint.pretty_print(module)
    pretty_signature = Dialyzer.PrettyPrint.pretty_print_contract(signature)

    """
    The @spec for the function does not match the success typing of
    the function.

    #{color(:yellow, "Function:")}
    #{pretty_module}.#{function}/#{arity}

    #{color(:yellow, "Success typing:")}
    @spec #{function}#{pretty_signature}
    """
  end
end
