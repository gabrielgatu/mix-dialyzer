defmodule Dialyzer.Plt.Manifest do
  alias Dialyzer.{Plt, Project}

  @spec changes() :: Keyword.t()
  def changes do
    manifest = read_manifest!()
    apps = all_applications()

    {apps_removed, apps_changed} =
      Enum.reduce(manifest[:apps], {[], []}, fn manifest_app, {removed, changed} ->
        case Enum.find(apps, &(&1.app == manifest_app.app)) do
          nil ->
            {[manifest_app | removed], changed}

          app ->
            case app.vsn == manifest_app.vsn do
              true -> {removed, changed}
              false -> {removed, [app | changed]}
            end
        end
      end)

    apps_added =
      Enum.filter(apps, fn app ->
        not Enum.any?(manifest[:apps], &(&1.app == app.app))
      end)

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

    Plt.Path.generate_deps_plt_hash_path()
    |> File.write!(inspect(content, limit: :infinity, printable_limit: :infinity))
  end

  @spec up_to_date?() :: boolean
  def up_to_date? do
    [apps: [added: [], removed: [], changed: []]] == changes()
  end

  @spec read_manifest!() :: [atom: any()]
  defp read_manifest! do
    Plt.Path.generate_deps_plt_hash_path()
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
