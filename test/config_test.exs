defmodule Dialyzer.ConfigTest do
  use ExUnit.Case
  import Dialyzer.Test.Util
  alias Dialyzer.{Config, Plt}

  setup_all do
    {_name, path} = create_temporary_project()
    %{path: path}
  end

  describe "when config file is not present" do
    test "it is missing from project root", %{path: path} do
      File.cd!(path, fn ->
        Config.path() |> File.rm()

        config_path = Config.path()
        refute File.exists?(config_path)
      end)
    end

    test "it creates a new configuration file in project root when trying to load it", %{
      path: path
    } do
      File.cd!(path, fn ->
        Config.path() |> File.rm()

        Config.load()
        config_path = Config.path()
        assert File.exists?(config_path)
      end)
    end
  end

  describe "when config file is present" do
    test "it is present in project root", %{path: path} do
      File.cd!(path, fn ->
        Config.load()
        path = Config.path()
        assert File.exists?(path)
      end)
    end

    test "it evaluates correctly the file", %{path: path} do
      File.cd!(path, fn ->
        config = Config.load()
        assert is_map(config)
      end)
    end

    test "it has default options setted correctly", %{path: path} do
      File.cd!(path, fn ->
        config = Config.load()
        assert config.apps == [remove: [], include: []]
        assert config.init_plt == Plt.Path.project_plt()
        assert config.warnings == Config.default_warnings()
      end)
    end
  end
end
