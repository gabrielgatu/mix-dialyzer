defmodule Dialyzer do
  alias Dialyzer.Config

  @spec run(Config.t()) :: none
  def run(config) do
    config
    |> Config.to_erlang_format()
    |> :dialyzer.run()
  end
end
