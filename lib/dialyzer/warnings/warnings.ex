defmodule Dialyzer.Warnings do
  alias Dialyzer.{Warning}
  import Dialyzer.Logger, only: [color: 2]

  @spec format_and_print(list(), Dialyzer.Config.t()) :: none
  def format_and_print(warnings, config) do
    warnings = Enum.map(warnings, &Warning.new/1)
    warnings_to_emit = ignore_warnings_excluded_from_config(warnings, config)

    print_header_stats(warnings, warnings_to_emit)
    print_stats(warnings, warnings_to_emit)
    print_footer()
    print_warnings(warnings_to_emit, config.cmd.msg_type)
  end

  @spec ignore_warnings_excluded_from_config([Warning.t()], Dialyzer.Config.t()) :: [Warning.t()]
  defp ignore_warnings_excluded_from_config(warnings, config) do
    extract_with_defaults = fn coll, index, default ->
      case Enum.at(coll, index) do
        nil -> default
        :* -> default
        val -> val
      end
    end

    Enum.filter(warnings, fn warning ->
      not Enum.any?(config.warnings[:ignore], fn ignored_warning ->
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
    end)
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
    #{color(:cyan, "{filepath, line, error}")} to the ignored warnings in #{color(:cyan, "`.dialyzer.exs`")}.

    To match more than one warning, use a placeholder (#{color(:cyan, ":*")}) instead of a specific value:
    #{color(:cyan, "{filepath, :*, error}")}

    When printing with the *long* format, the tuple to ignore a specific warning will be
    automatically printed for each warning!
    """
    |> IO.puts()
  end
end
