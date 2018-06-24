defmodule Dialyzer.Warnings.ContractDiff do
  @behaviour Dialyzer.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Warning
  @spec warning() :: :contract_diff
  def warning(), do: :contract_diff

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Type specification is not equal to the success typing."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([module, function, arity, contract, signature]) do
    pretty_module = Dialyzer.PrettyPrint.pretty_print(module)
    pretty_contract = Dialyzer.PrettyPrint.pretty_print_type(contract)
    pretty_signature = Dialyzer.PrettyPrint.pretty_print_type(signature)

    """
    Type specification is not equal to the success typing.

    #{color(:yellow, "Function:")}
    #{pretty_module}.#{function}/#{arity}

    #{color(:yellow, "Type specification:")}
    #{pretty_contract}

    #{color(:yellow, "Success typing:")}
    #{pretty_signature}
    """
  end
end
