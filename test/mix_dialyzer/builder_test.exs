defmodule Dialyzer.Plt.BuilderTest do
  use ExUnit.Case
  import Dialyzer.Test.Util

  alias Dialyzer.Plt.{Builder}
  alias Dialyzer.{Project, Config}

  describe "when requesting applications used to build plts" do
    test "it returns the correct list for the erlang plt" do
      in_project(:base_project, fn ->
        assert [:erts, :kernel, :stdlib, :crypto] == Builder.erlang_apps()
      end)
    end

    test "it returns the correct list for the elixir plt" do
      in_project(:base_project, fn ->
        expected = Builder.erlang_apps() ++ [:elixir, :mix]
        res = Builder.elixir_apps()

        assert expected == res
      end)
    end

    test "it returns the correct list for the project plt" do
      in_project(:base_project, fn ->
        expected_list = [Builder.erlang_apps(), Builder.elixir_apps(), Project.dependencies()]
        res = Builder.project_apps(Config.load())

        for expected_apps <- expected_list,
            expected_app <- expected_apps do
          assert expected_app in res
        end
      end)
    end
  end
end
