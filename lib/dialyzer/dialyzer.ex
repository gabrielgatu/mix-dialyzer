defmodule Dialyzer do
  alias Dialyzer.Config

  @spec run(Config.t()) :: none
  def run(config) do
    config
    |> Config.to_erlang_format()
    |> Kernel.++(check_plt: false)
    |> :dialyzer.run()
  end
end
