defmodule Dialyzer.Warnings.ImproperListConstruction do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :improper_list_constr
  def warning(), do: :improper_list_constr

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(args), do: format_long(args)

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([tl_type]) do
    pretty_type = Dialyzer.PrettyPrint.pretty_print_type(tl_type)

    "Cons will produce an improper list since its 2nd argument is #{pretty_type}."
  end
end
