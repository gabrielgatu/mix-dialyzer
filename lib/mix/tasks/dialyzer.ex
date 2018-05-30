defmodule Mix.Tasks.Dialyzer do
  @shortdoc "Runs static analysis via dialyzer"

  use Mix.Task

  def run(args) do
    Mix.Project.compile([])
    Dialyzer.Application.start(nil, nil)

    config =
      args
      |> Dialyzer.CommandLine.Config.parse()
      |> Dialyzer.Config.new()

    Dialyzer.Plt.ensure_loaded(config)
    Dialyzer.run(config) |> IO.inspect()

    # IO.puts("Starting Dialyzer")
    # {_, exit_status, result} = Dialyzer.dialyze(args)
    # Enum.each(result, &IO.puts/1)
  end
end
