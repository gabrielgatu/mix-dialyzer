defmodule Dialyzer.Plt.ManifestTest do
  use ExUnit.Case
  import Dialyzer.Test.Util
  alias Dialyzer.Config
  alias Dialyzer.Plt.{Manifest}

  setup_all do
    Application.ensure_started(:mix_dialyzer)
    {name, path} = create_temporary_project()
    %{name: name, path: path}
  end

  describe "when inside a new project" do
    test "it doesn't have a manifest file", %{name: name, path: path} do
      app = String.to_atom(name)

      Mix.Project.in_project(app, path, fn _ ->
        Manifest.path() |> File.rm()

        config = Config.new()
        assert Manifest.status(config) == :missing
      end)
    end
  end

  describe "when the manifest file exists" do
    test "it doesn't return :missing when requesting the status", %{name: name, path: path} do
      app = String.to_atom(name)

      Mix.Project.in_project(app, path, fn _ ->
        config = Config.new()
        Dialyzer.Plt.ensure_loaded(config)
        Manifest.update()

        assert Manifest.status(config) != :missing
      end)
    end

    test "it detects correctly the status", %{name: name, path: path} do
      app = String.to_atom(name)

      Mix.Project.in_project(app, path, fn _ ->
        config = Config.new()
        Dialyzer.Plt.ensure_loaded(config)
        Manifest.update()

        assert Manifest.status(config) == :up_to_date

        config = %Config{config | apps: [remove: [:kernel], include: []]}
        assert Manifest.status(config) == :outdated
      end)
    end

    test "it detects correctly the changes", %{name: name, path: path} do
      app = String.to_atom(name)

      Mix.Project.in_project(app, path, fn _ ->
        config = Config.new()
        Manifest.update()

        config = %Config{config | apps: [remove: [:kernel], include: []]}
        assert (Manifest.changes(config)[:apps][:removed] |> Enum.at(0) |> Map.fetch!(:app)) == :kernel
      end)
    end
  end
end
