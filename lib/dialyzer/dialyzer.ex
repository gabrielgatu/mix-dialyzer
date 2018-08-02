defmodule Dialyzer do
  import Dialyzer.Logger
  alias Dialyzer.Config

  @doc """
  It takes the project configuration and runs dialyzer according to it,
  by leaving removed applications/warnings off the analysis, and so on.

  It returns `:ok` if the analysis succeded without any warning from dialyzer,
  otherwise it returns `{:error, String.t()}`, with the second argument being
  the formatted output of the analysis.
  """
  @spec run(Config.t()) :: :ok | {:error, String.t()}
  def run(config) do
    Dialyzer.Plt.ensure_loaded(config)

    config
    |> Config.to_erlang_format()
    |> Dialyzer.Plt.Command.run()
    |> case do
      {:ok, []} ->
        :ok
      {:ok, warnings} ->
        {:error, Dialyzer.Warnings.format(warnings, config)}
      {:error, msg} ->
        {:error, error(":dialyzer.run error: #{msg}")}
    end
  end
end
