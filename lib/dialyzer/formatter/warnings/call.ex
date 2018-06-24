defmodule Dialyzer.Warnings.Call do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :call
  def warning(), do: :call

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "undefined function call"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "The function call will fail."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([
        module,
        function,
        args,
        arg_positions,
        fail_reason,
        signature_args,
        signature_return,
        contract
      ]) do
    pretty_args = Dialyzer.PrettyPrint.pretty_print_args(args)
    pretty_module = Dialyzer.PrettyPrint.pretty_print(module)

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

    #{pretty_module}.#{function}#{pretty_args}

    #{String.trim_trailing(call_string)}
    """
  end
end
