defmodule Dialyzer.Plt.Updater do
  alias Dialyzer.{Config, Plt}

  @doc """
  It updates the project plt by analyzing the manifest file,
  and updating only the applications that really changed.
  """
  @spec update(Config.t()) :: none
  def update(config) do
    changes = Plt.Manifest.changes(config)
    plt = Plt.Path.generate_deps_plt_path()

    removed_files =
      Enum.flat_map(changes[:apps][:removed] ++ changes[:apps][:changed], & &1.files)

    added_files = Enum.flat_map(changes[:apps][:changed] ++ changes[:apps][:added], & &1.files)

    Plt.Command.remove(plt, removed_files)
    Plt.Command.add(plt, added_files)
    Plt.Command.check(plt)

    Plt.Manifest.update()
  end
end
