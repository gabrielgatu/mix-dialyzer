defmodule Dialyzer.Warnings.ContractSubtype do
  @behaviour Dialyzer.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Warning
  @spec warning() :: :contract_subtype
  def warning(), do: :contract_subtype

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Type specification is a subtype of the success typing."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([module, function, arity, contract, signature]) do
    pretty_module = Dialyzer.PrettyPrint.pretty_print(module)
    pretty_signature = Dialyzer.PrettyPrint.pretty_print_contract(signature)
    pretty_contract = Dialyzer.PrettyPrint.pretty_print_contract(contract, module, function)

    """
    The type in the @spec does not completely cover the types returned
    by function.

    #{color(:yellow, "Function:")}
    #{pretty_module}.#{function}/#{arity}

    #{color(:yellow, "Type specification:")}
    @spec #{function}#{pretty_contract}

    #{color(:yellow, "Success typing:")}
    @spec #{function}#{pretty_signature}
    """
  end
end
