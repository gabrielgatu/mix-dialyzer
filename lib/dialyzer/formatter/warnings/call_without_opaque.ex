defmodule Dialyzer.Warnings.CallWithoutOpaque do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :call_without_opaque
  def warning(), do: :call_without_opaque

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Call without opaqueness type mismatch."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([module, function, args, expected_triples]) do
    pretty_module = Dialyzer.PrettyPrint.pretty_print(module)

    "The call #{pretty_module}.#{function}#{args} does not have #{
      form_expected_without_opaque(expected_triples)
    }."
  end

  # We know which positions N are to blame;
  # the list of triples will never be empty.
  defp form_expected_without_opaque([{position, type, type_string}]) do
    form_position_string = Dialyzer.WarningHelpers.form_position_string([position])

    message =
      if :erl_types.t_is_opaque(type) do
        "an opaque term of type #{type_string} in "
      else
        "a term of type #{type_string} (with opaque subterms) in "
      end

    message <> form_position_string
  end

  # TODO: can do much better here
  defp form_expected_without_opaque(expected_triples) do
    {arg_positions, _typess, _type_strings} = :lists.unzip3(expected_triples)
    form_position_string = Dialyzer.WarningHelpers.form_position_string(arg_positions)
    "opaque terms in #{form_position_string}"
  end
end
