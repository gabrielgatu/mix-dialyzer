defmodule Dialyzer.MixProject do
  use Mix.Project

  def project do
    [
      app: :mix_dialyzer,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Dialyzer.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    []
  end
end
