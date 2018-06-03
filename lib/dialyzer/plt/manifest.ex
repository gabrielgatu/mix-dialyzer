defmodule Dialyzer.Plt.Manifest do
  alias Dialyzer.{Config, Plt, Project}

  @type status :: :up_to_date | :outdated | :missing

  @spec status(Config.t()) :: status
  def status(config) do
    cond do
      not File.exists?(path()) -> :missing
      not Plt.plts_exists?() -> :missing
      [apps: [added: [], removed: [], changed: []]] == changes(config) -> :up_to_date
      true -> :outdated
    end
  end

  @spec changes(Config.t()) :: Keyword.t()
  def changes(config) do
    manifest = read_manifest!()

    apps =
      all_applications()
      |> Kernel.++(Enum.map(config.apps[:include], &Plt.App.info/1))
      |> Kernel.--(Enum.map(config.apps[:remove], &Plt.App.info/1))

    apps_added = apps_added(apps, manifest)
    apps_removed = apps_removed(apps, manifest)
    apps_changed = apps_changed(apps, manifest)

    [
      apps: [
        added: apps_added,
        removed: apps_removed,
        changed: apps_changed
      ]
    ]
  end

  @spec update() :: none
  def update do
    apps = all_applications()
    content = [apps: apps]

    path()
    |> File.write!(inspect(content, limit: :infinity, printable_limit: :infinity))
  end

  @spec path() :: binary
  def path(), do: Plt.Path.generate_deps_plt_path() <> ".manifest"

  @spec apps_added([Plt.App.t()], Keyword.t()) :: [atom]
  defp apps_added(apps, manifest) do
    apps
    |> Enum.filter(fn app ->
      not Enum.any?(manifest[:apps], fn manifest_app ->
        manifest_app.app == app.app
      end)
    end)
  end

  @spec apps_changed([Plt.App.t()], Keyword.t()) :: [atom]
  defp apps_changed(apps, manifest) do
    apps
    |> Enum.filter(fn app ->
      Enum.any?(manifest[:apps], fn manifest_app ->
        manifest_app.app == app.app and manifest_app.vsn != manifest_app.vsn
      end)
    end)
  end

  @spec apps_removed([Plt.App.t()], Keyword.t()) :: [atom]
  defp apps_removed(apps, manifest) do
    Enum.filter(manifest[:apps], fn manifest_app ->
      not Enum.any?(apps, &(&1.app == manifest_app.app))
    end)
  end

  @spec read_manifest!() :: Keyword.t()
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
end
