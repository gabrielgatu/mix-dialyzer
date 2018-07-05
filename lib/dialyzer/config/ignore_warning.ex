defmodule Dialyzer.Config.IgnoreWarning do
  defstruct [:file, :line, :warning]

  alias __MODULE__

  @type t :: %__MODULE__{}

  @spec new({String.t(), integer, atom}) :: t
  def new({file, line, warning}) do
    %IgnoreWarning{file: file, line: line, warning: warning}
  end

  @spec get_field_with_default(t, atom, any) :: any
  def get_field_with_default(ignore_warning, field, default) do
    ignore_warning
    |> Map.get(field)
    |> case do
      nil -> default
      :* -> default
      val -> val
    end
  end

  @spec associate_with_emitted_warnings([t], [Warning.t()]) :: [IgnoreWarning.Mapping.t()]
  def associate_with_emitted_warnings(ignored_warnings, emitted_warnings) do
    Enum.map(ignored_warnings, fn ignored_warning ->
      filtered_warns =
        Enum.filter(emitted_warnings, fn emitted_warning ->
          ignored_file = get_field_with_default(ignored_warning, :file, emitted_warning.file)
          ignored_line = get_field_with_default(ignored_warning, :line, emitted_warning.line)
          ignored_warn = get_field_with_default(ignored_warning, :warning, emitted_warning.name)

          cond do
            emitted_warning.file != ignored_file -> false
            emitted_warning.line != ignored_line -> false
            emitted_warning.name != ignored_warn -> false
            true -> true
          end
        end)

      IgnoreWarning.Mapping.new(ignored_warning, filtered_warns)
    end)
  end

  @spec find_suggestions_for_unmatched_warns([Warning.t()], t) :: [
          Warning.t()
        ]
  def find_suggestions_for_unmatched_warns(emitted_warnings, ignored_warning) do
    Enum.filter(emitted_warnings, fn emitted_warning ->
      ignored_file = get_field_with_default(ignored_warning, :file, emitted_warning.file)
      ignored_warn = get_field_with_default(ignored_warning, :warning, emitted_warning.name)

      cond1 = emitted_warning.file == ignored_file and emitted_warning.name == ignored_warn

      cond2 =
        (fn ->
           warn1 = Atom.to_string(emitted_warning.name)
           warn2 = Atom.to_string(ignored_warn)
           emitted_warning.file == ignored_file and String.jaro_distance(warn1, warn2) > 0.8
         end).()

      cond1 or cond2
    end)
  end

  @spec to_ignore_format(t) :: {String.t(), integer, atom}
  def to_ignore_format(ignore_warning) do
    file = get_field_with_default(ignore_warning, :file, :*)
    line = get_field_with_default(ignore_warning, :line, :*)
    warning = get_field_with_default(ignore_warning, :warning, :*)

    {file, line, warning}
  end
end
