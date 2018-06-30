defmodule Dialyzer.Formatter.Warnings.NoReturn do
  @behaviour Dialyzer.Formatter.Warning

  @impl Dialyzer.Formatter.Warning
  @spec warning() :: :no_return
  def warning(), do: :no_return

  @impl Dialyzer.Formatter.Warning
  @spec name() :: String.t()
  def name(), do: "no return"

  @impl Dialyzer.Formatter.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "The function has no return"
  end

  @impl Dialyzer.Formatter.Warning
  @spec format_long([String.t() | atom]) :: String.t()
  def format_long([type | name]) do
    name_string =
      case name do
        [] ->
          "The created fun"

        [function, arity] ->
          "Function #{function}/#{arity}"
      end

    type_string =
      case type do
        :no_match ->
          "has no clauses that will ever match."

        :only_explicit ->
          "only terminates with explicit exception."

        :only_normal ->
          "has no local return."

        :both ->
          "has no local return."
      end

    """
    The function has no return. This is usually due to an issue later
    on in the call stack causing it to not be recognized as returning
    for some reason. It is often helpful to cross reference the
    complete list of warnings with the call stack in the function and
    fix the deepest part of the call stack, which will usually fix
    many of the other no_return errors.

    #{name_string} #{type_string}
    """
  end
end
