defmodule Dialyzer.ConfigTest do
  use ExUnit.Case
  import Dialyzer.Test.Util
  alias Dialyzer.{Config, Plt}

  setup do
    on_exit fn ->
      in_project(:missing_config, fn ->
        Config.path() |> File.rm()
      end)
    end
  end

  describe "when config file is not present" do
    test "it is missing from project root" do
      in_project(:missing_config, fn ->
        config_path = Config.path()
        refute File.exists?(config_path)
      end)
    end

    test "it creates a new configuration file in project root when trying to load it" do
      in_project(:missing_config, fn ->
        Config.load()

        config_path = Config.path()
        assert File.exists?(config_path)
      end)
    end
  end

  describe "when config file is present" do
    test "it is present in project root" do
      in_project(:base_project, fn ->
        Config.load()
        path = Config.path()
        assert File.exists?(path)
      end)
    end

    test "it evaluates correctly the file" do
      in_project(:base_project, fn ->
        config = Config.load()
        assert is_map(config)
      end)
    end

    test "it has default options setted correctly" do
      in_project(:base_project, fn ->
        config = Config.load()
        assert config.apps == [remove: [], include: []]
        assert config.init_plt == Plt.Path.project_plt()
        assert config.warnings[:active] == Config.default_warnings()
      end)
    end
  end

  describe "when it is ignoring a warning" do
    test "it has a tuple inside the ignored warnings" do
      in_project(:complex_project, fn ->
        config = Config.load()

        expected = {"lib/mod.ex", 5, :no_return}
        assert expected in config.warnings[:ignore]
      end)
    end

    test "it parses correctly the tuple" do
      in_project(:complex_project, fn ->
        config = Config.load()

        expected = {"lib/mod.ex", 5, :no_return}
        res = Config.IgnoreWarning.new(expected)

        assert res.file == elem(expected, 0)
        assert res.line == elem(expected, 1)
        assert res.warning == elem(expected, 2)
      end)
    end

    test "it extracts the value or a default from the tuple" do
      in_project(:complex_project, fn ->
        config = Config.load()

        expected = {"lib/mod.ex", :*, :no_return}
        res = Config.IgnoreWarning.new(expected)

        assert res.file == Config.IgnoreWarning.get_field_with_default(res, :file, nil)
        assert :none == Config.IgnoreWarning.get_field_with_default(res, :line, :none)
      end)
    end
  end
end
