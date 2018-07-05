defmodule Dialyzer.Config.IgnoreWarning.Mapping do
  defstruct [:ignore_warning, :warnings]

  alias __MODULE__
  alias Dialyzer.{Config.IgnoreWarning, Warning}

  @type t :: %__MODULE__{}

  @spec new(IgnoreWarning.t(), [Warning.t()]) :: t
  def new(ignore_warning, warnings) do
    %Mapping{ignore_warning: ignore_warning, warnings: warnings}
  end

  @spec filter_warnings_to_emit([Warning.t()], [t]) :: [Warning.t()]
  def filter_warnings_to_emit(warnings, mappings) do
    Enum.filter(warnings, fn warning ->
      not Enum.any?(mappings, fn mapping ->
        warning in mapping.warnings
      end)
    end)
  end

  @spec filter_unmatched_warnings([t]) :: [IgnoreWarning.t()]
  def filter_unmatched_warnings(warnings_to_ignore) do
    warnings_to_ignore
    |> Enum.filter(fn mapping ->
      mapping.warnings == []
    end)
    |> Enum.map(fn mapping -> mapping.ignore_warning end)
  end
end
