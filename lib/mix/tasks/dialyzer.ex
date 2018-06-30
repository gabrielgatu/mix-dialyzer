defmodule Mix.Tasks.Dialyzer do
  @shortdoc "Runs static analysis via dialyzer"

  use Mix.Task

  def run(args) do
    Mix.Project.compile([])
    Application.ensure_all_started(:mix_dialyzer)

    args
    |> Dialyzer.CommandLine.Config.parse()
    |> Dialyzer.Config.load()
    |> Dialyzer.run()
  end
end
