defmodule Dialyzer.Plt.ManifestTest do
  use ExUnit.Case
  import Dialyzer.Test.Util
  alias Dialyzer.Config
  alias Dialyzer.Plt.{Manifest}

  setup_all do
    Application.ensure_all_started(:mix_dialyzer)
    {name, path} = create_temporary_project()
    %{name: name, path: path}
  end

  describe "when inside a new project" do
    test "it doesn't have a manifest file", %{name: name, path: path} do
      app = String.to_atom(name)

      Mix.Project.in_project(app, path, fn _ ->
        Manifest.path() |> File.rm()

        config = Config.load()
        assert Manifest.status(config) == :missing
      end)
    end
  end

  describe "when the manifest file exists" do
    test "it doesn't return :missing when requesting the status", %{name: name, path: path} do
      app = String.to_atom(name)

      Mix.Project.in_project(app, path, fn _ ->
        config = Config.load()
        Dialyzer.Plt.ensure_loaded(config)
        Manifest.update()

        assert Manifest.status(config) != :missing
      end)
    end

    test "it detects correctly the status", %{name: name, path: path} do
      app = String.to_atom(name)

      Mix.Project.in_project(app, path, fn _ ->
        config = Config.load()
        Dialyzer.Plt.ensure_loaded(config)
        Manifest.update()

        assert Manifest.status(config) == :up_to_date

        config = %Config{config | apps: [remove: [:kernel], include: []]}
        assert Manifest.status(config) == :outdated
      end)
    end

    test "it detects correctly if the apps changes", %{name: name, path: path} do
      app = String.to_atom(name)

      Mix.Project.in_project(app, path, fn _ ->
        config = Config.load()
        Manifest.update()

        config = %Config{config | apps: [remove: [:kernel], include: []]}
        assert Manifest.changes(config)[:files][:removed] |> Enum.count() > 0
      end)
    end
  end
end
