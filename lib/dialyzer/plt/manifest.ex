defmodule Dialyzer.Plt.Manifest do
  alias Dialyzer.{Plt, Project}

  @spec changes() :: [atom: any]
  def changes do
    manifest = read_manifest!()

    apps = all_applications()
    lockfile_hash = generate_lock_file_hash()

    {apps_removed, apps_changed} =
      Enum.reduce(apps, {[], []}, fn app, {removed, changed} ->
        case Enum.find(manifest[:apps], &(&1.app == app.app)) do
          nil ->
            {[app | removed], changed}

          manifest_app ->
            case manifest_app.vsn == app.vsn do
              true -> {removed, changed}
              false -> {removed, [app | changed]}
            end
        end
      end)

    apps_added =
      Enum.filter(manifest[:apps], fn manifest_app ->
        Enum.any?(apps, &(&1.app == manifest_app.app))
      end)

    [
      apps: [
        added: apps_added,
        removed: apps_removed,
        changed: apps_changed
      ],
      # TODO: I think we don't need anymore the lock file hash, because
      # we are already tracking dependency versions through the app.vsn
      lock_file_changed: manifest[:hash][:lockfile] == lockfile_hash
    ]
  end

  @spec update() :: none
  def update do
    lockfile_hash = generate_lock_file_hash()
    apps = all_applications()

    content = [hash: [lockfile: lockfile_hash], apps: apps]

    generate_deps_plt_hash_path()
    |> File.write!(inspect(content, limit: :infinity, printable_limit: :infinity))
  end

  @spec up_to_date?() :: boolean
  def up_to_date? do
    changes = changes()

    changes[:apps][:added] == [] and changes[:apps][:removed] == [] and
      changes[:apps][:changed] == [] and changes[:lock_file_changed] == false
  end

  @spec generate_lock_file_hash() :: binary
  defp generate_lock_file_hash do
    lock_file = Mix.Dep.Lock.read() |> :erlang.term_to_binary()
    :crypto.hash(:sha, lock_file)
  end

  @spec read_manifest!() :: [atom: any()]
  defp read_manifest! do
    generate_deps_plt_hash_path()
    |> Code.eval_file()
    |> elem(0)
  end

  @spec generate_deps_plt_hash_path() :: String.t()
  defp generate_deps_plt_hash_path, do: Plt.generate_deps_plt_path() <> ".hash"

  @spec all_applications() :: [Plt.App.t()]
  defp all_applications do
    Project.dependencies()
    |> Kernel.++([Project.application()])
    |> Enum.map(&Plt.App.info/1)
    |> Enum.filter(&(not is_nil(&1)))
  end
end
