defmodule Dialyzer do
  alias Dialyzer.Config

  @spec run(Config.t()) :: [String.t()]
  def run(config) do
    Dialyzer.Plt.ensure_loaded(config)

    config
    |> Config.to_erlang_format()
    |> Kernel.++(check_plt: false)
    |> :dialyzer.run()
    |> Dialyzer.Formatter.format(config.cmd.msg_type)
  end
end
