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
  import Dialyzer.Logger
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
      delete_file(Plt.Path.project_plt()),
      delete_file(Plt.Manifest.path()),
      if(all_active, do: delete_folder(Plt.Path.home_dir()), else: "")
    ]

    logs =
      deletions
      |> Enum.filter(&(&1 != ""))
      |> Enum.join("\n")

    if info_active do
      if logs != "" do
        Mix.shell().info("""

        #{color(:yellow, "## Files deleted")}
        """)

        Mix.shell().info(logs)
      else
        Mix.shell().info("""

        #{color(:yellow, "## No files to delete")}
        """)
      end
    end
  end

  @spec delete_file(binary) :: String.t()
  defp delete_file(filepath) do
    case File.rm(filepath) do
      :ok ->
        """
        #{color(:cyan, "* success")} - #{filepath}
        """

      {:error, :enoent} ->
        ""

      {:error, reason} ->
        """
        #{color(:cyan, "* failure")} - error during deletion of #{filepath}: #{color(:yellow, inspect(reason))}
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
          #{color(:cyan, "* success")} - #{filepath}
          """
        end)
        |> Enum.join("\n")

      {:error, :enoent, _filepath} ->
        ""

      {:error, reason, filepath} ->
        """
        #{color(:cyan, "* failure")} - error during deletion of #{filepath}: #{color(:yellow, inspect(reason))}
        """
    end
  end
end
