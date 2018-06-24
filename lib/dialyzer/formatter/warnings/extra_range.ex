defmodule Dialyzer.Warnings.ExtraRange do
  @behaviour Dialyzer.Warning
  import Dialyzer.Logger, only: [color: 2]

  @impl Dialyzer.Warning
  @spec warning() :: :extra_range
  def warning(), do: :extra_range

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short([module, function, arity, _extra_ranges, _signature_range]) do
    pretty_module = Dialyzer.PrettyPrint.pretty_print(module)

    "@spec for #{pretty_module}.#{function}/#{arity} has more types " <>
      "than returned by function."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([module, function, arity, extra_ranges, signature_range]) do
    pretty_module = Dialyzer.PrettyPrint.pretty_print(module)
    pretty_extra = Dialyzer.PrettyPrint.pretty_print_type(extra_ranges)
    pretty_signature = Dialyzer.PrettyPrint.pretty_print_type(signature_range)

    """
    The @spec says the function returns more types than the function actually returns.

    #{color(:yellow, "Function:")}
    #{pretty_module}.#{function}/#{arity}

    #{color(:yellow, "Extra type:")}
    #{pretty_extra}

    #{color(:yellow, "Success typing:")}
    #{pretty_signature}
    """
  end
end
