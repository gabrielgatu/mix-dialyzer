defmodule Dialyzer.Warnings.CallWithOpaque do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :call_with_opaque
  def warning(), do: :call_with_opaque

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Call with opaqueness type mismatch."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([module, function, args, arg_positions, expected_args]) do
    pretty_module = Dialyzer.PrettyPrint.pretty_print(module)

    """
    The call #{pretty_module}.#{function}#{args} contains #{form_positions(arg_positions)}
    when #{form_expected(expected_args)}}.
    """
  end

  defp form_positions(arg_positions = [_]) do
    form_position_string = Dialyzer.WarningHelpers.form_position_string(arg_positions)
    "an opaque term in #{form_position_string} argument"
  end

  defp form_positions(arg_positions) do
    form_position_string = Dialyzer.WarningHelpers.form_position_string(arg_positions)
    "opaque terms in #{form_position_string} arguments"
  end

  defp form_expected([type]) do
    type_string = :erl_types.t_to_string(type)

    if :erl_types.t_is_opaque(type) do
      "an opaque term of type #{type_string} is expected"
    else
      "a structured term of type #{type_string} is expected"
    end
  end

  defp form_expected(_expected_args) do
    "terms of different types are expected in these positions"
  end
end
