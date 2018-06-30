defmodule Dialyzer.Formatter.Warnings.CallToMissingFunction do
  @behaviour Dialyzer.Formatter.Warning

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :call_to_missing
  def warning(), do: :call_to_missing

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "undefined function call"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short([module, function, arity]) do
    pretty_module = Dialyzer.Formatter.PrettyPrint.pretty_print(module)

    "Call to missing or private function #{pretty_module}.#{function}/#{arity}."
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([module, function, arity]) do
    pretty_module = Dialyzer.Formatter.PrettyPrint.pretty_print(module)

    """
    Call to missing or private function. May be a typo, or
    incorrect arity.

    #{pretty_module}.#{function}/#{arity}.
    """
  end
end
