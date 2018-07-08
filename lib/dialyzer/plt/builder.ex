defmodule Dialyzer.Plt.Builder do
  alias Dialyzer.{Config, Project, Plt}
  require Logger

  @doc """
  It builds incrementally all the plts and checks
  for their consistency through dialyzer.
  """
  @spec build(Config.t()) :: none
  def build(config) do
    Plt.missing_plts()
    |> Enum.each(fn plt -> build_plt(plt, config) end)
  end

  @doc """
  It returns the apps used to build the erlang plt.
  """
  @spec erlang_apps :: [atom]
  def erlang_apps, do: [:erts, :kernel, :stdlib, :crypto]

  @doc """
  It returns the apps used to build the elixir plt.
  """
  @spec elixir_apps :: [atom]
  def elixir_apps, do: erlang_apps() ++ [:elixir]

  @doc """
  It returns the apps used to build the project plt.
  """
  @spec project_apps(Config.t()) :: [atom]
  def project_apps(config) do
    removed_apps = config.apps[:remove]
    included_apps = config.apps[:include]

    Project.dependencies()
    |> Kernel.++(Project.applications())
    |> Kernel.++(elixir_apps())
    |> Kernel.++(included_apps)
    |> Kernel.--(removed_apps)
  end

  @spec build_plt(atom, Config.t()) :: none
  defp build_plt(:erlang, _config) do
    path = Plt.Path.erlang_plt()
    apps = erlang_apps() |> Enum.map(&Plt.App.info/1)
    prev_plt_apps = []

    ensure_dir_accessible!(path)
    Plt.Command.new(path)
    build_plt(path, apps, prev_plt_apps)
  end

  defp build_plt(:elixir, _config) do
    path = Plt.Path.elixir_plt()
    apps = elixir_apps() |> Enum.map(&Plt.App.info/1)
    prev_plt_apps = erlang_apps() |> Enum.map(&Plt.App.info/1)

    Plt.Command.copy(Plt.Path.erlang_plt(), path)
    build_plt(path, apps, prev_plt_apps)
  end

  defp build_plt(:project, config) do
    path = Plt.Path.project_plt()
    apps = project_apps(config) |> Enum.map(&Plt.App.info/1) |> Enum.filter(&(&1 != nil))
    prev_plt_apps = elixir_apps() |> Enum.map(&Plt.App.info/1)

    Plt.Command.copy(Plt.Path.elixir_plt(), path)
    build_plt(path, apps, prev_plt_apps)
  end

  defp build_plt(path, apps, prev_plt_apps) do
    ensure_dir_accessible!(path)

    plt_files = collect_files_from_apps(apps)
    prev_plt_files = collect_files_from_apps(prev_plt_apps)

    remove = MapSet.difference(prev_plt_files, plt_files)
    add = MapSet.difference(plt_files, prev_plt_files)

    Plt.Command.remove(path, remove)
    Plt.Command.add(path, add)
    Plt.Command.check(path)
  end

  @spec collect_files_from_apps([Plt.App.t()]) :: MapSet.t()
  defp collect_files_from_apps(apps) do
    Enum.flat_map(apps, fn app -> Enum.map(app.mods, & &1.filepath) end)
    |> MapSet.new()
  end

  @spec ensure_dir_accessible!(String.t()) :: none
  defp ensure_dir_accessible!(dir) do
    case :filelib.ensure_dir(dir) do
      :ok ->
        nil

      {:error, error} ->
        raise "Could not write: #{dir}. Error: #{to_string(error)}"
    end
  end
end
