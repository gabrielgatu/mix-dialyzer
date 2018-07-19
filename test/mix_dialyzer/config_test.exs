defmodule Dialyzer.ConfigTest do
  use ExUnit.Case
  import Dialyzer.Test.Util
  alias Dialyzer.{Warning, Config, Plt}

  setup do
    on_exit(fn ->
      in_project(:missing_config, fn ->
        Config.path() |> File.rm()
      end)
    end)
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

        expected = {"lib/mod.ex", -1, :no_return}
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

    test "it associates correctly with an emitted warning" do
      in_project(:complex_project, fn ->
        config = Config.load()

        ignored_warning = {"lib/mod.ex", 5, :no_return}
        res_ignored = Config.IgnoreWarning.new(ignored_warning)

        emitted_warning =
          {:warn_return_no_exit, {'lib/mod.ex', 5}, {:no_return, [:only_normal, :call_add, 0]}}

        res_emitted = Warning.new(emitted_warning)

        [res] = Config.IgnoreWarning.associate_with_emitted_warnings([res_ignored], [res_emitted])
        assert res.ignore_warning == res_ignored
        assert res_emitted in res.warnings
      end)
    end

    test "it finds suggestions for an unmatched warning" do
      in_project(:complex_project, fn ->
        config = Config.load()

        ignored_warning = {"lib/mod.ex", 7, :no_return}
        res_ignored = Config.IgnoreWarning.new(ignored_warning)

        emitted_warning =
          {:warn_return_no_exit, {'lib/mod.ex', 5}, {:no_return, [:only_normal, :call_add, 0]}}

        res_emitted = Warning.new(emitted_warning)

        [res] =
          Config.IgnoreWarning.find_suggestions_for_unmatched_warns([res_emitted], res_ignored)

        assert res == res_emitted
      end)
    end

    test "it formats correctly a warning into the tuple format" do
      ignored_warning = {"lib/mod.ex", 7, :no_return}
      res_ignored = Config.IgnoreWarning.new(ignored_warning)

      tuple = Config.IgnoreWarning.to_ignore_format(res_ignored)
      assert res_ignored.file == elem(tuple, 0)
      assert res_ignored.line == elem(tuple, 1)
      assert res_ignored.warning == elem(tuple, 2)
    end

    test "it filters the warnings to emit excluding the ignored ones" do
      in_project(:complex_project, fn ->
        config = Config.load()

        ignored_warning = {"lib/mod.ex", 7, :no_return}
        res_ignored = Config.IgnoreWarning.new(ignored_warning)

        emitted_warning =
          {:warn_return_no_exit, {'lib/mod.ex', 5}, {:no_return, [:only_normal, :call_add, 0]}}

        res_emitted = Warning.new(emitted_warning)

        mappings =
          Config.IgnoreWarning.associate_with_emitted_warnings([res_ignored], [res_emitted])

        [res] = Config.IgnoreWarning.Mapping.filter_warnings_to_emit([res_emitted], mappings)

        assert res == res_emitted
      end)
    end

    test "it filters the unmatched warnings" do
      in_project(:complex_project, fn ->
        config = Config.load()

        ignored_warning = {"lib/mod.ex", 7, :no_return}
        res_ignored = Config.IgnoreWarning.new(ignored_warning)

        emitted_warning =
          {:warn_return_no_exit, {'lib/mod.ex', 5}, {:no_return, [:only_normal, :call_add, 0]}}

        res_emitted = Warning.new(emitted_warning)

        mappings =
          Config.IgnoreWarning.associate_with_emitted_warnings([res_ignored], [res_emitted])

        res = Config.IgnoreWarning.Mapping.filter_unmatched_warnings(mappings)

        assert res == [res_ignored]
      end)
    end
  end
end
