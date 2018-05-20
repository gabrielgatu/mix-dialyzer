defmodule Dialyzer.Project do

  @doc """
  Get the name of the current application
  """
  @spec application() :: atom
  def application do
    Mix.Project.get().project()[:app]
  end

  @doc """
  Return all the dependencies (direct or indirect) of this project.
  """
  @spec dependencies() :: [atom]
  def dependencies do
    # compile & load all deps paths
    Mix.Tasks.Deps.Loadpaths.run([])
    # compile & load current project paths
    Mix.Project.compile([])

    project_deps()
    |> Enum.sort()
    |> Enum.uniq()
  end

  @doc """
  Return an array with the absolute paths for all the build paths of this project.
  Normally a single element will be returned, since most project just have the _build dir.
  """
  @spec build_paths() :: [String.t()]
  def build_paths, do: build_paths([])

  @spec build_paths([String.t()]) :: [String.t()]
  defp build_paths(acc) do
    if Mix.Project.umbrella?() do
      children = Mix.Dep.Umbrella.loaded()

      Enum.reduce(children, acc, fn child, acc ->
        Mix.Project.in_project(child.app, child.opts[:path], fn _ ->
          build_paths(acc)
        end)
      end)
    else
      [Mix.Project.compile_path() | acc]
    end
  end

  # Works by recursively analyzing all the deps of this project, as well
  # as all the deps of deps, returning them as a list of application names.
  @spec project_deps() :: [atom]
  defp project_deps, do: project_deps([])

  @spec project_deps([atom]) :: [atom]
  defp project_deps(acc) do
    if Mix.Project.umbrella?() do
      children = Mix.Dep.Umbrella.loaded()

      Enum.reduce(children, acc, fn child, acc ->
        Mix.Project.in_project(child.app, child.opts[:path], fn _ ->
          project_deps(acc)
        end)
      end)
    else
      acc ++ project_core_deps() ++ project_transitive_deps()
    end
  end

  # Retrieve all the deps to the core elixir. Be careful: this will not return
  # project imported dependencies, but just the deps required from the core elixir
  # system, such as :kernel, :stdlib and so forth.
  @spec project_core_deps() :: [atom]
  defp project_core_deps() do
    Mix.Project.config()
    |> Keyword.get(:app)
    |> project_core_deps()
  end

  # Load each app and recursively build a list of all the core application deps
  # For each app, log also to the user an error in case of incomplete dep list.
  @spec project_core_deps(atom()) :: [atom]
  defp project_core_deps(app) do
    Application.load(app) |> log_app_load_issues(app)
    Application.spec(app, :applications) |> find_project_core_deps()
  end

  # In case of error during the loading of an app, sometimes the error is due an incomplete
  # dependency list, then log it to the user.
  # TODO: Improve this doc.
  defp log_app_load_issues(:ok, _), do: nil
  defp log_app_load_issues({:error, {:already_loaded, _}}, _), do: nil

  defp log_app_load_issues({:error, err}, app),
    do: IO.puts("Error loading #{app}, dependency list may be incomplete.\n #{err}")

  # Recursively reduce all applications found
  # TODO: Improve this doc.
  defp find_project_core_deps([]), do: []
  defp find_project_core_deps(nil), do: []

  defp find_project_core_deps(apps) do
    apps
    |> Enum.map(&project_core_deps/1)
    |> List.flatten()
    |> Enum.concat(apps)
  end

  # Return a list of all the transitive dependencies this project has.
  # This means direct and indirect dependencies (deps of deps).
  @spec project_transitive_deps() :: [atom]
  defp project_transitive_deps do
    Mix.Project.deps_paths() |> Map.keys()
  end
end
