defmodule Dialyzer do
  import Dialyzer.Logger
  alias Dialyzer.Config

  @spec run(Config.t()) :: String.t()
  def run(config) do
    Dialyzer.Plt.ensure_loaded(config)

    config
    |> Config.to_erlang_format()
    |> Dialyzer.Plt.Command.run()
    |> case do
      {:ok, warnings} ->
        Dialyzer.Warnings.format(warnings, config)
      {:error, msg} ->
        error(":dialyzer.run error: #{msg}")
    end
  end
end
