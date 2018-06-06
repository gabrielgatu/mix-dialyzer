defmodule Dialyzer.Plt.Builder do
  alias Dialyzer.{Config, Project, Plt}
  require Logger

  @doc """
  It builds incrementally all the plts and checks
  for their consistency through dialyzer.
  """
  @spec build(Config.t()) :: none
  def build(config) do
    config |> plts_list() |> check_plts()
  end

  @doc """
  Generates a list of 3 elements.
  The first element referes to the erlang plt,
  the second element referes to the elixir plt and
  the third element referes to the project level plt.
  """
  @spec plts_list(Config.t()) :: [Plt.t()]
  def plts_list(config) do
    removed_apps = config.apps[:remove]
    included_apps = config.apps[:include]

    erlang_apps = [:erts, :kernel, :stdlib, :crypto] -- removed_apps
    elixir_apps = ([:elixir] ++ erlang_apps) -- removed_apps

    project_apps =
      Project.dependencies()
      |> Kernel.++([Project.application()])
      |> Kernel.++(elixir_apps)
      |> Kernel.++(erlang_apps)
      |> Kernel.++(included_apps)
      |> Kernel.--(removed_apps)

    [
      %Plt{
        name: :erlang,
        path: Plt.Path.generate_erlang_plt_path(),
        apps: Enum.map(erlang_apps, &Plt.App.info/1)
      },
      %Plt{
        name: :elixir,
        path: Plt.Path.generate_elixir_plt_path(),
        apps: Enum.map(elixir_apps, &Plt.App.info/1)
      },
      %Plt{
        name: :project,
        path: Plt.Path.generate_deps_plt_path(),
        apps: Enum.map(project_apps, &Plt.App.info/1)
      }
    ]
  end

  defp check_plts(plts), do: check_plts(plts, nil)
  defp check_plts([], _), do: nil

  @spec check_plts([Plt.t()], Plt.t() | nil) :: none
  defp check_plts([plt | rest], nil) do
    ensure_dir_accessible!(plt.path)
    plt_files = collect_files_from_apps(plt.apps)

    Plt.Command.new(plt.path)
    Plt.Command.add(plt.path, plt_files)
    Plt.Command.check(plt.path)

    check_plts(rest, plt)
  end

  defp check_plts([plt | rest], prev_plt) do
    Plt.Command.copy(prev_plt.path, plt.path)

    plt_files = collect_files_from_apps(plt.apps)
    prev_plt_files = collect_files_from_apps(prev_plt.apps)

    remove = MapSet.difference(prev_plt_files, plt_files)
    add = MapSet.difference(plt_files, prev_plt_files)

    Plt.Command.remove(plt.path, remove)
    Plt.Command.add(plt.path, add)
    Plt.Command.check(plt.path)

    check_plts(rest, plt)
  end

  @spec collect_files_from_apps([Plt.App.t()]) :: MapSet.t()
  defp collect_files_from_apps(apps) do
    MapSet.new(Enum.flat_map(apps, & &1.files))
  end

  @spec ensure_dir_accessible!(String.t()) :: none
  defp ensure_dir_accessible!(dir) do
    case :filelib.ensure_dir(dir) do
      :ok ->
        nil

      {:error, error} ->
        raise "Could not access: #{Plt.Path.home_dir()}. Error: #{to_string(error)}"
    end
  end
end
