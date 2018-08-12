defmodule Dialyzer.Project do
  @doc """
  Get the name of the applications defined at the root.

  In case of umbrella projects, this is a list of all
  the applications defined inside `/apps`.
  """
  @spec applications() :: [atom]
  def applications do
    if Mix.Project.umbrella?() do
      Mix.Dep.Umbrella.loaded() |> Enum.map(& &1.app)
    else
      [Mix.Project.get().project()[:app]]
    end
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
end

defmodule Dialyzer.Project.DepedencyGraph do
  alias __MODULE__

  def sources(deps) do
    deps
    |> Enum.map(&:code.which/1)
    |> Enum.filter(&(not is_atom(&1)))
  end

  def dependencies(app) do
    case Application.spec(app) do
      nil ->
        mod_dependencies(app)

      spec ->
        mod_dependencies(List.first(spec[:modules]))
    end
  end

  def mod_dependencies(mod) do
    case DepedencyGraph.Cache.get(mod) do
      :error ->
        {deps, visited} = calc_dependencies(mod)
        deps = Enum.uniq(deps)
        DepedencyGraph.Cache.save(mod, {deps, visited})
        deps

      {:ok, {deps, _visited}} ->
        deps
    end
  end

  def calc_dependencies(mod, visited \\ []) do
    case DepedencyGraph.Cache.get(mod) do
      :error ->
        case module_references(mod) do
          [] ->
            {[], visited}

          mods ->
            mods
            |> Enum.filter(&(&1 not in visited))
            |> Enum.reduce({[], [mod | visited]}, fn ref_mod, {res, visited} ->
              {deps, visited} = calc_dependencies(ref_mod, visited)
              res = Enum.uniq([ref_mod | deps] ++ res)
              {res, visited}
            end)
        end

      {:ok, deps} ->
        deps
    end
  end

  def module_references(mod) do
    try do
      forms = :forms.read(mod)

      calls =
        :forms.filter(
          fn
            {:call, _, {:remote, _, {:atom, _, _}, _}, _} -> true
            {:atom, _, <<>>} -> true
            _ -> false
          end,
          forms
        )

      modules = for {:call, _, {:remote, _, {:atom, _, module}, _}, _} <- calls, do: module
      Enum.uniq(modules)
    rescue
      _ -> []
    catch
      _ -> []
    end
  end
end

defmodule Dialyzer.Project.DepedencyGraph.Cache do
  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(mod) do
    Agent.get(__MODULE__, fn state ->
      Map.fetch(state, mod)
    end)
  end

  def save(mod, deps) do
    Agent.update(__MODULE__, fn state ->
      Map.put(state, mod, deps)
    end)
  end
end
