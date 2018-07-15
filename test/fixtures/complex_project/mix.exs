defmodule ComplexProject.Mixfile do
  use Mix.Project

  def project do
    [app: :complex_project, version: "0.1.0", deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:mix_dialyzer, path: "../../../", only: [:dev]}
    ]
  end
end
