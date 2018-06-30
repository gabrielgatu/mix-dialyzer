defmodule Dialyzer.Formatter.Warnings.ContractSupertype do
  @behaviour Dialyzer.Formatter.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :contract_supertype
  def warning(), do: :contract_supertype

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Type specification is a supertype of the success typing."
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([module, function, arity, contract, signature]) do
    pretty_module = Dialyzer.Formatter.PrettyPrint.pretty_print(module)
    pretty_contract = Dialyzer.Formatter.PrettyPrint.pretty_print_contract(contract)
    pretty_signature = Dialyzer.Formatter.PrettyPrint.pretty_print_contract(signature)

    """
    The @spec, while not incorrect, is more general than the type
    returned by the function.

    #{color(:yellow, "Function:")}
    #{pretty_module}.#{function}/#{arity}

    #{color(:yellow, "Type specification:")}
    @spec #{function}#{pretty_contract}

    #{color(:yellow, "Success typing:")}
    @spec #{function}#{pretty_signature}
    """
  end
end
