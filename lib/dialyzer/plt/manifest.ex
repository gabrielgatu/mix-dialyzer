defmodule Dialyzer.Plt.Manifest do
  alias Dialyzer.{Config, Plt, Project}

  @type manifest :: Keyword.t()
  @type status :: :up_to_date | :outdated | :missing

  @doc """
  It returns the plt status of the project:
    * :missing - when plt / manifest file is missing
    * :outdated - when an application / module has been changed
    * :up_to_date - when nothing needs to be updated
  """
  @spec status(Config.t()) :: status
  def status(config) do
    cond do
      not File.exists?(path()) -> :missing
      not Plt.plts_exists?() -> :missing
      [files: [added: [], removed: [], changed: []]] == changes(config) -> :up_to_date
      true -> :outdated
    end
  end

  @doc """
  It returns a keyword list with all the changes detected inside
  the project.
  """
  @spec changes(Config.t()) :: manifest
  def changes(config) do
    manifest = read_manifest!()

    apps =
      all_applications()
      |> Kernel.++(Enum.map(config.apps[:include], &Plt.App.info/1))
      |> Kernel.--(Enum.map(config.apps[:remove], &Plt.App.info/1))

    files_added = mods_added(apps, manifest) |> Plt.App.files()
    files_removed = mods_removed(apps, manifest) |> Plt.App.files()
    files_changed = mods_changed(apps, manifest) |> Plt.App.files()

    [
      files: [
        added: files_added,
        removed: files_removed,
        changed: files_changed
      ]
    ]
  end

  @doc """
  It updates the manifest file by saving the current enviroment.
  """
  @spec update() :: none
  def update do
    apps = all_applications()
    hashes = generate_hashes_for_builded_mods()
    content = [apps: apps, hashes: hashes]

    path()
    |> File.write!(inspect(content, limit: :infinity, printable_limit: :infinity))
  end

  @doc """
  It returns the path for the manifest file.
  """
  @spec path() :: binary
  def path(), do: Plt.Path.generate_deps_plt_path() <> ".manifest"

  @spec mods_added([Plt.App.t()], manifest) :: [atom]
  defp mods_added(apps, manifest) do
    apps
    |> Stream.map(fn app ->
      manifest_app = Enum.find(manifest[:apps], &(&1.app == app.app))
      {app, manifest_app}
    end)
    |> Stream.filter(fn {_app, manifest_app} -> manifest_app == nil end)
    |> Stream.flat_map(& &1.mods)
    |> Enum.to_list()
  end

  @spec mods_changed([Plt.App.t()], manifest) :: [atom]
  defp mods_changed(apps, manifest) do
    apps
    |> Stream.map(fn app ->
      manifest_app = Enum.find(manifest[:apps], &(&1.app == app.app))
      {app, manifest_app}
    end)
    |> Stream.filter(fn {_app, manifest_app} -> manifest_app != nil end)
    |> Stream.transform([], fn {app, manifest_app}, acc ->
      case app.vsn == manifest_app.vsn do
        true -> {filter_modules_changed(app.mods, manifest) ++ acc, acc}
        false -> {app.mods ++ acc, acc}
      end
    end)
    |> Enum.to_list()
  end

  @spec mods_removed([Plt.App.t()], manifest) :: [atom]
  defp mods_removed(apps, manifest) do
    manifest[:apps]
    |> Stream.filter(fn manifest_app ->
      not Enum.any?(apps, &(&1.app == manifest_app.app))
    end)
    |> Stream.flat_map(& &1.mods)
    |> Enum.to_list()
  end

  @spec read_manifest!() :: manifest
  defp read_manifest! do
    path()
    |> Code.eval_file()
    |> elem(0)
  end

  @spec all_applications() :: [Plt.App.t()]
  defp all_applications do
    Project.dependencies()
    |> Kernel.++([Project.application()])
    |> Enum.map(&Plt.App.info/1)
    |> Enum.filter(&(not is_nil(&1)))
  end

  @spec generate_hashes_for_builded_mods :: Map.t()
  defp generate_hashes_for_builded_mods do
    Mix.Utils.extract_files(Project.build_paths(), [:beam])
    |> Enum.reduce(%{}, fn filepath, acc ->
      mod = filepath |> to_charlist() |> :beam_lib.info() |> Keyword.fetch!(:module)
      [{_filepath, hash}] = :dialyzer_plt.compute_md5_from_files([to_charlist(filepath)])

      Map.put(acc, mod, hash)
    end)
  end

  @spec filter_modules_changed([atom], manifest) :: [atom]
  defp filter_modules_changed(mods, manifest) do
    hashes = generate_hashes_for_builded_mods()

    Enum.filter(mods, fn mod ->
      case Map.fetch(hashes, mod) do
        :error ->
          false

        {:ok, hash} ->
          Map.get(manifest[:hashes], mod) != hash
      end
    end)
  end
end
