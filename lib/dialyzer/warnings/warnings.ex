defmodule Dialyzer.Warnings do
  alias Dialyzer.{Warning, Config.IgnoreWarning}
  import Dialyzer.Logger, only: [color: 2]

  @spec format_and_print(list(), Dialyzer.Config.t()) :: none
  def format_and_print(warnings, config) do
    warnings = Enum.map(warnings, &Warning.new/1)

    ignored_tuples = Enum.map(config.warnings[:ignore], &IgnoreWarning.new/1)

    warning_mappings =
      IgnoreWarning.associate_with_emitted_warnings(ignored_tuples, warnings)

    warnings_to_emit = IgnoreWarning.Mapping.filter_warnings_to_emit(warnings, warning_mappings)
    warnings_without_mapping = IgnoreWarning.Mapping.filter_unmatched_warnings(warning_mappings)

    print_header_stats(warnings, warnings_to_emit)
    print_stats(warnings, warnings_to_emit)
    print_footer()
    print_warnings(warnings_to_emit, config.cmd.msg_type)
    print_warnings_without_mapping(warnings_to_emit, warnings_without_mapping)
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

  @spec print_warnings_without_mapping([Warning.t()], [IgnoreWarning.t()]) :: none
  defp print_warnings_without_mapping(emitted_warnings, warnings_without_mapping) do
    if Enum.count(warnings_without_mapping) > 0 do
      message =
        Enum.reduce(warnings_without_mapping, "", fn warning, acc ->
          header = "\n\n- #{color(:yellow, inspect(IgnoreWarning.to_ignore_format(warning)))}"

          emitted_warnings
          |> IgnoreWarning.find_suggestions_for_unmatched_warns(warning)
          |> case do
            [] ->
              header

            matches ->
              formatted_matches = Enum.reduce(matches, "", fn match, acc ->
                ignore_warning_tuple = Warning.to_ignore_format(match)
                acc <>
                  "\n    #{
                    color(:cyan, inspect(ignore_warning_tuple, limit: :infinity, printable_limit: :infinity))
                  }"
              end)

              header
              |> Kernel.<>("\n\n    From the warnings emitted I have found these warnings that could have been the ones you were trying to ignore:\n")
              |> Kernel.<>(formatted_matches)
              |> Kernel.<>(acc)
          end
        end)

      """

      No match has been found for these ignored warnings you specified in #{
        color(:cyan, "`.dialyzer.exs`")
      }:

      #{message |> String.trim()}
      """
      |> IO.puts()
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
    #{color(:cyan, "{filepath, line, warning}")} to the ignored warnings in #{
      color(:cyan, "`.dialyzer.exs`")
    }.

    To match more than one warning, use a placeholder (#{color(:cyan, ":*")}) instead of a specific value:
    #{color(:cyan, "{filepath, :*, warning}")}

    When printing with the *long* format, the tuple to ignore a specific warning will be
    automatically printed for each warning!
    """
    |> IO.puts()
  end
end
