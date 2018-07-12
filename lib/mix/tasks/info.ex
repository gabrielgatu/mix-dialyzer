defmodule Mix.Tasks.Dialyzer.Info do
  @shortdoc "Gets informations about the dialyzer enviroment"
  @moduledoc """
  Displays some informations about your dialyzer enviroment,
  like analyzed applications and dependencies, active and ignored
  warnings, build paths analyzed and so on.
  """

  use Mix.Task
  import Dialyzer.Logger

  @warning_info [
    error_handling: "Include warnings for functions that only return by an exception.",
    no_behaviours:
      "Suppress warnings about behavior callbacks that drift from the published recommended interfaces.",
    no_contracts: "Suppress warnings about invalid contracts.",
    no_fail_call: "Suppress warnings for failing calls.",
    no_fun_app: "Suppress warnings for fun applications that will fail.",
    no_improper_lists: "Suppress warnings for construction of improper lists.",
    no_match: "Suppress warnings for patterns that are unused or cannot match.",
    no_missing_calls: "Suppress warnings about calls to missing functions.",
    no_opaque: "Suppress warnings for violations of opacity of data types.",
    no_return: "Suppress warnings for functions that will never return a value.",
    no_undefined_callbacks:
      "Suppress warnings about behaviors that have no -callback attributes for their callbacks.",
    no_unused: "Suppress warnings for unused functions.",
    race_conditions:
      "Include warnings for possible race conditions. Notice that the analysis that finds data races performs intra-procedural data flow analysis and can sometimes explode in time. Enable it at your own risk.",
    underspecs:
      "Warn about underspecified functions (the specification is strictly more allowing than the success typing).",
    unknown:
      "Let warnings about unknown functions and types affect the exit status of the command-line version. The default is to ignore warnings about unknown functions and types when setting the exit status. When using Dialyzer from Erlang, warnings about unknown functions and types are returned; the default is not to return these warnings.",
    unmatched_returns:
      "Include warnings for function calls that ignore a structured return value or do not match against one of many possible return value(s).",
    overspecs:
      "Warn about overspecified functions (the specification is strictly less allowing than the success typing).",
    specdiffs: "Warn when the specification is different than the success typing."
  ]

  def run(_args) do
    Mix.Project.compile([])
    _ = Application.ensure_all_started(:mix_dialyzer)

    config = Dialyzer.Config.load()

    IO.puts("""

    Welcome to mix dialyzer! A tool for integrating dialyzer into a project and analyzing discrepances.
    Here are some infos about your system:

    #{color(:yellow, "## Application name")}

    #{application_name()}

    #{color(:yellow, "## Applications included into analysis")}

    #{applications_analyzed(config)}

    #{color(:yellow, "## Applications removed from analysis")}

    #{applications_not_analyzed(config)}

    #{color(:yellow, "## Warnings currently active")}

    #{warnings_analyzed(config)}

    #{color(:yellow, "## Warnings ignored")}

    #{warnings_not_analyzed(config)}

    #{color(:yellow, "## Build directories found")}

    #{build_directories(config)}

    #{color(:yellow, "## More infos")}

    If you want to read more about dialyzer itself, here you can find some nice infos:
    - http://learnyousomeerlang.com/dialyzer A general guide to what dialyzer is and how it works
    - http://erlang.org/doc/man/dialyzer.html Official documentation
    """)
  end

  defp application_name do
    Dialyzer.Project.applications()
    |> Enum.reduce("", fn app, acc ->
      acc <>
        """
        #{color(:cyan, "* #{app}")}
        """
    end)
    |> String.trim()
  end

  defp applications_analyzed(config) do
    erlang_apps = Dialyzer.Plt.Builder.erlang_apps()
    elixir_apps = Dialyzer.Plt.Builder.elixir_apps() -- erlang_apps

    project_apps =
      config
      |> Dialyzer.Plt.Builder.project_apps()
      |> Kernel.--(elixir_apps)
      |> Kernel.--(Dialyzer.Project.applications())

    str = format_applications_analyzed_section("Erlang applications", erlang_apps)
    str = str <> format_applications_analyzed_section("Elixir applications", elixir_apps)
    str = str <> format_applications_analyzed_section("Project applications", project_apps)
    str
  end

  defp format_applications_analyzed_section(section_name, apps) do
    Enum.reduce(apps, "", fn app, acc ->
      acc <>
        """
          #{color(:cyan, "* #{app}")}
        """
    end)
    |> case do
      "" ->
        "[]"

      str ->
        """

          #{color(:yellow, "### #{section_name}")}

        """ <> str
    end
  end

  defp applications_not_analyzed(config) do
    config.apps[:remove]
    |> Enum.reduce("", fn app, acc ->
      acc <>
        """
        #{color(:cyan, "* #{app.app}")}
        """
    end)
    |> case do
      "" -> "[]"
      str -> str
    end
  end

  defp warnings_analyzed(config) do
    Enum.reduce(config.warnings[:active], "", fn warning, acc ->
      acc <>
        """
        #{color(:cyan, "* #{warning}")} - #{@warning_info[warning]}

        """
    end)
    # To eliminate blank line at the end
    |> String.trim()
    |> case do
      "" -> "[]"
      str -> str
    end
  end

  defp warnings_not_analyzed(config) do
    warnings = Keyword.keys(@warning_info) -- config.warnings

    Enum.reduce(warnings, "", fn warning, acc ->
      acc <>
        """
        #{color(:cyan, "* #{warning}")} - #{@warning_info[warning]}

        """
    end)
    # To eliminate blank line at the end
    |> String.trim()
    |> case do
      "" -> "[]"
      str -> str
    end
  end

  defp build_directories(config) do
    Enum.reduce(config.build_dir, "", fn dir, acc ->
      acc <>
        """
        #{color(:cyan, "* #{dir}")}

        """
    end)
    |> String.trim()
  end
end
