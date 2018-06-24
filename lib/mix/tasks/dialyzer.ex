defmodule Mix.Tasks.Dialyzer do
  @shortdoc "Runs static analysis via dialyzer"

  use Mix.Task

  def run(args) do
    Mix.Project.compile([])
    Application.ensure_started(:mix_dialyzer)

    warnings =
      args
      |> Dialyzer.CommandLine.Config.parse()
      |> Dialyzer.Config.load()
      |> Dialyzer.run()

    IO.puts("\n")

    warnings
    |> Enum.each(fn message ->
      IO.puts(message)
    end)
  end
end
