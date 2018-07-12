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
      Plt.missing_plts() != [] -> :missing
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

    files_added = files_added(apps, manifest)
    files_removed = files_removed(apps, manifest)
    files_changed = files_changed(apps, manifest)

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
  @spec update() :: :ok
  def update do
    apps = all_applications()
    content = [apps: apps]

    write_content = inspect(content, limit: :infinity, printable_limit: :infinity)
    File.write!(path(), write_content)

    :ok
  end

  @doc """
  It returns the path for the manifest file.
  """
  @spec path() :: binary
  def path(), do: Plt.Path.project_plt() <> ".manifest"

  @spec files_added([Plt.App.t()], manifest) :: [atom]
  defp files_added(apps, manifest) do
    apps
    |> Stream.map(fn app ->
      manifest_app = Enum.find(manifest[:apps], &(&1.app == app.app))
      {app, manifest_app}
    end)
    |> Stream.filter(fn {_app, manifest_app} -> manifest_app == nil end)
    |> Stream.map(fn {app, _manifest_app} -> app end)
    |> Stream.flat_map(& &1.mods)
    |> Stream.map(& &1.filepath)
    |> Enum.to_list()
  end

  @spec files_changed([Plt.App.t()], manifest) :: [atom]
  defp files_changed(apps, manifest) do
    apps
    |> Stream.map(fn app ->
      manifest_app = Enum.find(manifest[:apps], &(&1.app == app.app))
      {app, manifest_app}
    end)
    |> Stream.filter(fn {_app, manifest_app} -> manifest_app != nil end)
    |> Stream.transform([], fn {app, manifest_app}, acc ->
      case app.vsn == manifest_app.vsn do
        true -> {filter_modules_changed(app) ++ acc, acc}
        false -> {app.mods ++ acc, acc}
      end
    end)
    |> Stream.map(& &1.filepath)
    |> Enum.to_list()
  end

  @spec files_removed([Plt.App.t()], manifest) :: [atom]
  defp files_removed(apps, manifest) do
    manifest[:apps]
    |> Stream.map(fn manifest_app ->
      app = Enum.find(apps, &(&1.app == manifest_app.app))
      {app, manifest_app}
    end)
    |> Stream.transform([], fn {app, manifest_app}, acc ->
      case {app, manifest_app} do
        {nil, manifest_app} ->
          {manifest_app.mods ++ acc, acc}

        {app, manifest_app} ->
          removed_mods = manifest_app.mods -- app.mods
          {removed_mods ++ acc, acc}
      end
    end)
    |> Stream.map(& &1.filepath)
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
    |> Kernel.++(Project.applications())
    |> Enum.map(&Plt.App.info/1)
    |> Enum.filter(&(not is_nil(&1)))
  end

  @spec filter_modules_changed(Plt.App.t()) :: [atom]
  defp filter_modules_changed(app) do
    compiled_mods_with_md5 =
      Mix.Utils.extract_files(Project.build_paths(), [:beam])
      |> Enum.reduce(%{}, fn filepath, acc ->
        mod = filepath |> to_charlist() |> :beam_lib.info() |> Keyword.fetch!(:module)
        md5 = apply(mod, :module_info, [:md5])

        Map.put(acc, mod, md5)
      end)

    Enum.filter(app.mods, fn mod ->
      case Map.fetch(compiled_mods_with_md5, mod) do
        :error ->
          false

        {:ok, hash} ->
          mod.md5 != hash
      end
    end)
  end
end
