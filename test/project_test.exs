defmodule Dialyzer.ProjectTest do
  use ExUnit.Case
  import Dialyzer.Test.Util
  alias Dialyzer.{Project}

  setup_all do
    {name, path} = create_temporary_project()
    %{name: name, path: path}
  end

  describe "when inside a project" do
    test "it gets correctly the application name", %{name: name, path: path} do
      app = String.to_atom(name)

      Mix.Project.in_project(app, path, fn _ ->
        assert Project.applications() == [app]
      end)
    end

    test "it gets direct dependencies", %{name: name, path: path} do
      Mix.Project.in_project(String.to_atom(name), path, fn _ ->
        assert :logger in Project.dependencies()
      end)
    end

    test "it gets transitive dependencies", %{name: name, path: path} do
      Mix.Project.in_project(String.to_atom(name), path, fn _ ->
        assert :elixir in Project.dependencies()
      end)
    end

    test "it gets all the build paths", %{name: name, path: path} do
      app = String.to_atom(name)

      Mix.Project.in_project(app, path, fn _ ->
        assert Enum.count(Project.build_paths()) == 1
      end)
    end
  end
end
