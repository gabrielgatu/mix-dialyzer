defmodule MissingConfig.Mixfile do
  use Mix.Project

  def project do
    [app: :missing_config, version: "0.1.0", deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end
end
