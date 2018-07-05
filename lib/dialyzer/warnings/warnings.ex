defmodule Dialyzer.Warnings do
  alias Dialyzer.{Warning}
  import Dialyzer.Logger, only: [color: 2]

  @type ignored_warning :: {String.t(), integer, atom}
  @type warning_mapping :: {ignored_warning, [Warning.t()]}

  @spec format_and_print(list(), Dialyzer.Config.t()) :: none
  def format_and_print(warnings, config) do
    warnings = Enum.map(warnings, &Warning.new/1)
    warning_mappings = find_warning_mappings(warnings, config)

    warnings_to_emit = filter_warnings_to_emit(warnings, warning_mappings)
    warnings_without_mapping = filter_warnings_without_mapping(warning_mappings)

    print_header_stats(warnings, warnings_to_emit)
    print_stats(warnings, warnings_to_emit)
    print_footer()
    print_warnings(warnings_to_emit, config.cmd.msg_type)
    print_warnings_without_mapping(warnings_without_mapping)
  end

  @spec print_header_stats([Warning.t()], [Warning.t()]) :: none
  defp print_header_stats(warnings, warnings_to_emit) do
    """

    #{color(:yellow, "* STATS")}

    #{color(:cyan, "Number of warnings emitted:")} #{Enum.count(warnings_to_emit)}
    #{color(:cyan, "Number of warnings ignored:")} #{
      Enum.count(warnings) - Enum.count(warnings_to_emit)
    }

    """
    |> IO.puts()
  end

  @spec print_stats([Warning.t()], [Warning.t()]) :: none
  defp print_stats(warnings, warnings_to_emit) do
    warnings
    |> Enum.group_by(fn warning -> warning.name end)
    |> Enum.map(fn {warning_name, warnings} ->
      num_warnings = Enum.count(warnings)

      num_ignored =
        num_warnings -
          (fn ->
             warnings_to_emit
             |> Enum.filter(&(&1.name == warning_name))
             |> Enum.count()
           end).()

      %{warning: warning_name, num_ignored: num_ignored, num_emitted: num_warnings}
    end)
    |> Scribe.print(style: Scribe.Style.Pseudo)
  end

  @spec print_warnings([Warning.t()], :short | :long) :: none
  defp print_warnings(warnings, format) do
    IO.puts(color(:yellow, "* WARNINGS\n"))

    warnings
    |> Dialyzer.Formatter.format(format)
    |> Enum.each(fn message ->
      IO.puts(message)
    end)
  end

  @spec print_warnings_without_mapping([{String.t(), integer, atom}]) :: none
  defp print_warnings_without_mapping(warnings) do
    if Enum.count(warnings) > 0 do
      warnings = Enum.reduce(warnings, "", fn warning, acc ->
        acc <> "- #{color(:cyan, inspect(warning))}"
      end)

      """

      No match has been found for these ignored warnings you specified in #{color(:cyan, "`.dialyzer.exs`")}:

      #{warnings}
      """ |> IO.puts()
    end
  end

  @spec print_footer() :: none
  defp print_footer do
    """

    #{color(:yellow, "* INFOS")}

    To get more informations about the warnings, as well as your project,
    like analyzed applications, avaiable/active/ignored warnings, build paths examined, ...
    use the mix command: #{color(:cyan, "`mix dialyzer.info`")}

    To ignore a set of warnings (ie: :underspecs warnings), just remove the
    warning atom from the active warnings in #{color(:cyan, "`.dialyzer.exs`")}

    To ignore a specific warning, add a tuple with the format
    #{color(:cyan, "{filepath, line, warning}")} to the ignored warnings in #{color(:cyan, "`.dialyzer.exs`")}.

    To match more than one warning, use a placeholder (#{color(:cyan, ":*")}) instead of a specific value:
    #{color(:cyan, "{filepath, :*, warning}")}

    When printing with the *long* format, the tuple to ignore a specific warning will be
    automatically printed for each warning!
    """
    |> IO.puts()
  end

  @spec find_warning_mappings([Warning.t()], Dialyzer.Config.t()) :: [{tuple, Warning.t()}]
  defp find_warning_mappings(warnings, config) do
    extract_with_defaults = fn coll, index, default ->
      case Enum.at(coll, index) do
        nil -> default
        :* -> default
        val -> val
      end
    end

    Enum.map(config.warnings[:ignore], fn ignored_warning ->
      res = Enum.filter(warnings, fn warning ->
        ignored_warning = Tuple.to_list(ignored_warning)

        ignored_file = extract_with_defaults.(ignored_warning, 0, warning.file)
        ignored_line = extract_with_defaults.(ignored_warning, 1, warning.line)
        ignored_warn = extract_with_defaults.(ignored_warning, 2, warning.name)

        cond do
          warning.file != ignored_file -> false
          warning.line != ignored_line -> false
          warning.name != ignored_warn -> false
          true -> true
        end
      end)

      {ignored_warning, res}
    end)
  end

  @spec filter_warnings_to_emit([Warning.t()], [warning_mapping]) :: [Warning.t()]
  defp filter_warnings_to_emit(warnings, warnings_to_ignore) do
    Enum.filter(warnings, fn warning ->
      not Enum.any?(warnings_to_ignore, fn {_, warns} ->
        warning in warns
      end)
    end)
  end

  @spec filter_warnings_without_mapping([warning_mapping]) :: [warning_mapping]
  defp filter_warnings_without_mapping(warnings_to_ignore) do
    warnings_to_ignore
    |> Enum.filter(fn {_ignored_warn, found_warns} ->
      found_warns == []
    end)
    |> Enum.map(fn {ignored_warn, _found_warns} -> ignored_warn end)
  end
end
