defmodule Dialyzer.Warnings.Apply do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :apply
  def warning(), do: :apply

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "undefined function call"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Function call will not succeed."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([args, arg_positions, fail_reason, signature_args, signature_return, contract]) do
    pretty_args = Dialyzer.PrettyPrint.pretty_print_args(args)

    call_string =
      Dialyzer.WarningHelpers.call_or_apply_to_string(
        arg_positions,
        fail_reason,
        signature_args,
        signature_return,
        contract
      )

    """
    The function being invoked exists, and has the correct arity, but
    will not succeed, because there is a mismatch with the arguments.

    #{pretty_args} #{call_string}
    """
  end
end
