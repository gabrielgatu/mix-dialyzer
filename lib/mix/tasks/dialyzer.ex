defmodule Mix.Tasks.Dialyzer do
  @shortdoc "Runs static analysis via dialyzer"
  @moduledoc """
  Runs a discrepancy analysis through dialyzer and logs
  the warnings found.

  The analysis can be configured via the `.dialyzer.exs` file,
  in your project root.

  ## Command line options

  - --short - uses the "short" version to format the outputted warnings
  - --long - uses the "long" version to format the outputted warnings.

  ## Short formatting

  The short version is a single line containing the file/line and a brief
  description of the warning.

  ## Long formatting

  The long version is a multiline containing the file/line and a detailed
  description of the warning, as well as the expected type from dialyzer
  and a tuple to ignore the file, to add to the `.dialyzer.exs` file.

  ## Usage

  By default, when mix.dialyzer is executed, the short formatting
  is used.

  If you want to format with the long format, run:

      `mix dialyzer --long`
  """

  use Mix.Task

  def run(args) do
    Mix.Project.compile([])
    _ = Application.ensure_all_started(:mix_dialyzer)

    args
    |> Dialyzer.CommandLine.Config.parse()
    |> Dialyzer.Config.load()
    |> Dialyzer.run()
    |> IO.puts()
  end
end
