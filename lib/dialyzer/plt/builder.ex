defmodule Dialyzer.Plt.Builder do
  @moduledoc """
  The builder is responsable for building a plt from zero,
  by including all the necessary modules, and using pre-existing
  plt to build over them and speed things up.
  """

  alias Dialyzer.{Config, Project, Plt}
  require Logger

  @doc """
  It builds incrementally all the plts.
  """
  @spec build(Config.t()) :: :ok
  def build(config) do
    Enum.each(Plt.missing_plts(), fn plt -> build_plt(plt, config) end)
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
  def elixir_apps, do: erlang_apps() ++ [:elixir, :mix]

  @doc """
  It returns the apps used to build the project plt.
  """
  @spec project_apps(Config.t()) :: [atom]
  def project_apps(config) do
    removed_apps = config.apps[:remove]
    included_apps = config.apps[:include]

    Project.dependencies()
    |> Kernel.++(elixir_apps())
    |> Enum.uniq()
    |> Kernel.++(included_apps)
    |> Kernel.--(removed_apps)
    |> Enum.uniq()
  end

  @spec build_plt(atom, Config.t()) :: {:ok, list} | {:error, any}
  defp build_plt(:erlang, _config) do
    path = Plt.Path.erlang_plt()
    apps = erlang_apps() |> Enum.map(&Plt.App.info/1)
    prev_plt_apps = []

    ensure_dir_accessible!(path)
    _ = Plt.Command.new(path)
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

    _ = Plt.Command.remove(path, Enum.to_list(remove))
    _ = Plt.Command.add(path, Enum.to_list(add))
  end

  @spec collect_files_from_apps([Plt.App.t()]) :: MapSet.t()
  defp collect_files_from_apps(apps) do
    Enum.flat_map(apps, fn app ->
      app
      |> Map.fetch!(:mods)
      |> Enum.map(& &1.filepath)
      |> Enum.filter(&(not is_atom(&1)))
    end)
    |> MapSet.new()
  end

  @spec ensure_dir_accessible!(String.t()) :: :ok | :error
  defp ensure_dir_accessible!(dir) do
    case :filelib.ensure_dir(dir) do
      :ok ->
        :ok

      {:error, error} ->
        raise "Could not write: #{dir}. Error: #{to_string(error)}"
        :error
    end
  end
end
