defmodule Dialyzer.MixProject do
  use Mix.Project

  def project do
    [
      app: :mix_dialyzer,
      version: "0.2.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      mod: {Dialyzer.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:erlex, "~> 0.1.0"},
      {:scribe, "~> 0.8"},
      {:forms, "~> 0.0.1"},
      {:excoveralls, "~> 0.8", only: [:test]}
    ]
  end

  defp aliases do
    [
      test: [
        "run ./test.setup.exs",
        "test"
      ]
    ]
  end
end
