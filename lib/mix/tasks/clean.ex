defmodule Mix.Tasks.Dialyzer.Clean do
  @shortdoc "Cleans all the artifacts built by dialyzer (plts, caches, manifest files)"
  @moduledoc """
  Cleans all the artifacts built by dialyzer.

  ## Command line options

  - --info - logs informations about files deleted, warnings and errors
  - --all - removes also the erlang and elixir plts

  ## Usage

  By default, when dialyzer.clean is executed, only the project level artifacts
  used by dialyzer will be deleted.

  If you want to delete all the dialyzer artifacts, use the `--all` option.

      `mix dialyzer.clean --all`

  ## .dialyzer.exs

  The configuration file for running dialyzer will never be touched.
  If you want to remove completely all the dialyzer related files
  from your project, run:
      `mix dialyzer.clean --all`

  and then remove manually the .dialyzer.exs file.
  """

  use Mix.Task
  require Logger
  alias Dialyzer.Plt

  @command_options [
    info: :boolean,
    all: :boolean
  ]

  def run(args) do
    {opts, _, _} = OptionParser.parse(args, strict: @command_options)
    info_active = Keyword.get(opts, :info, false)
    all_active = Keyword.get(opts, :all, false)

    deletions = [
      delete_file(Plt.Path.generate_deps_plt_path()),
      delete_file(Plt.Manifest.path()),
      if(all_active, do: delete_folder(Plt.Path.home_dir()), else: "")
    ]

    logs =
      deletions
      |> Enum.filter(&(&1 != ""))
      |> Enum.join("\n")

    if info_active and logs != "" do
      Mix.shell().info("""

      #{yellow("## Files deleted")}
      """)

      Mix.shell().info(logs)
    else
      Mix.shell().info("""

      #{yellow("## No files to delete")}
      """)
    end
  end

  @spec delete_file(binary) :: String.t()
  defp delete_file(filepath) do
    case File.rm(filepath) do
      :ok ->
        """
        #{cyan("* success")} - #{filepath}
        """

      {:error, :enoent} ->
        ""

      {:error, reason} ->
        """
        #{cyan("* failure")} - error during deletion of #{filepath}: #{yellow(inspect(reason))}
        """
    end
  end

  @spec delete_folder(binary) :: String.t()
  defp delete_folder(path) do
    case File.rm_rf(path) do
      {:ok, files} ->
        files
        |> Enum.map(fn filepath ->
          """
          #{cyan("* success")} - #{filepath}
          """
        end)
        |> Enum.join("\n")

      {:error, :enoent, _filepath} ->
        ""

      {:error, reason, filepath} ->
        """
        #{cyan("* failure")} - error during deletion of #{filepath}: #{yellow(inspect(reason))}
        """
    end
  end

  defp cyan(item) do
    IO.ANSI.format([:cyan, item])
  end

  defp yellow(item) do
    IO.ANSI.format([:yellow, item])
  end
end
