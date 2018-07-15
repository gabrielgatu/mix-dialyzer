defmodule Dialyzer.Plt.ManifestTest do
  use ExUnit.Case
  import Dialyzer.Test.Util
  alias Dialyzer.Config
  alias Dialyzer.Plt.{Manifest}

  describe "when inside a new project" do
    test "it doesn't have a manifest file" do
      in_project(:base_project, fn ->
        Manifest.path() |> File.rm()

        config = Config.load()
        assert Manifest.status(config) == :missing
      end)
    end
  end

  describe "when the manifest file exists" do
    test "it doesn't return :missing when requesting the status" do
      in_project(:base_project, fn ->
        config = Config.load()
        Dialyzer.Plt.ensure_loaded(config)
        Manifest.update()

        assert Manifest.status(config) != :missing
      end)
    end

    test "it detects correctly the status" do
      in_project(:base_project, fn ->
        config = Config.load()
        Dialyzer.Plt.ensure_loaded(config)
        Manifest.update()

        assert Manifest.status(config) == :up_to_date

        config = %Config{config | apps: [remove: [:kernel], include: []]}
        assert Manifest.status(config) == :outdated
      end)
    end

    test "it detects correctly if the apps changes" do
      in_project(:base_project, fn ->
        config = Config.load()
        Manifest.update()

        config = %Config{config | apps: [remove: [:kernel], include: []]}
        assert Manifest.changes(config)[:files][:removed] |> Enum.count() > 0
      end)
    end
  end
end
