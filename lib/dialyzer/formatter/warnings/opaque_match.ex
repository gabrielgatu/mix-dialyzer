defmodule Dialyzer.Warnings.OpaqueMatch do
  @behaviour Dialyzer.Warning

  @impl Dialyzer.Warning
  @spec warning() :: :opaque_match
  def warning(), do: :opaque_match

  @impl Dialyzer.Warning
  @spec name() :: String.t()
  def name(), do: "type mismatch"

  @impl Dialyzer.Warning
  @spec format_short([String.t()]) :: String.t()
  def format_short(_) do
    "Attempted to match against opaque term."
  end

  @impl Dialyzer.Warning
  @spec format_long([String.t()]) :: String.t()
  def format_long([pattern, opaque_type, opaque_term]) do
    term =
      if opaque_type == opaque_term do
        "the term"
      else
        opaque_term
      end

    pretty_pattern = Dialyzer.PrettyPrint.pretty_print(pattern)

    """
    The attempt to match a term of type #{opaque_term} against the #{pretty_pattern}
    breaks the opaqueness of #{term}.
    """
  end
end
