defmodule Dialyzer.ProjectTest do
  use ExUnit.Case
  import Dialyzer.Test.Util
  alias Dialyzer.{Project}

  describe "when inside a project" do
    test "it gets correctly the application name" do
      in_project(:base_project, fn ->
        assert Project.applications() == [:base_project]
      end)
    end

    test "it gets direct dependencies" do
      in_project(:base_project, fn ->
        assert :logger in Project.dependencies()
      end)
    end

    test "it gets transitive dependencies" do
      in_project(:base_project, fn ->
        assert :elixir in Project.dependencies()
      end)
    end

    test "it gets all the build paths" do
      in_project(:base_project, fn ->
        assert Enum.count(Project.build_paths()) == 1
      end)
    end
  end
end
