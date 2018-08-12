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

    Project.applications()
    |> Kernel.++(included_apps)
    |> Kernel.--(removed_apps)
    |> Enum.uniq()
  end

  @spec build_plt(atom, Config.t()) :: {:ok, list} | {:error, any}
  defp build_plt(:erlang, _config) do
    path = Plt.Path.erlang_plt()
    files = retrieve_all_files_used_in_apps(erlang_apps())

    ensure_dir_accessible!(path)
    _ = Plt.Command.new(path)
    build_plt(path, files)
  end

  defp build_plt(:elixir, _config) do
    path = Plt.Path.elixir_plt()
    files = retrieve_all_files_used_in_apps(elixir_apps())

    Plt.Command.copy(Plt.Path.erlang_plt(), path)
    build_plt(path, files)
  end

  defp build_plt(:project, config) do
    path = Plt.Path.project_plt()
    files = retrieve_all_files_used_in_apps(project_apps(config))

    Plt.Command.copy(Plt.Path.elixir_plt(), path)
    build_plt(path, files)
  end

  defp build_plt(path, files) do
    ensure_dir_accessible!(path)
    _ = Plt.Command.add(path, Enum.to_list(files))
  end

  defp retrieve_all_files_used_in_apps(apps) do
    apps
    |> Enum.map(&Dialyzer.Project.DepedencyGraph.dependencies/1)
    |> List.flatten()
    |> Enum.uniq()
    |> Dialyzer.Project.DepedencyGraph.sources()
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
