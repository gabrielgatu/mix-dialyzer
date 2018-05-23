defmodule Dialyzer.Plt.Updater do
  alias Dialyzer.{Plt}

  @spec update() :: none
  def update do
    changes = Plt.Manifest.changes()
    plt = Plt.Path.generate_deps_plt_path()

    removed_files =
      Enum.flat_map(changes[:apps][:removed] ++ changes[:apps][:changed], & &1.files)

    added_files = Enum.flat_map(changes[:apps][:changed] ++ changes[:apps][:added], & &1.files)

    Plt.Command.plt_remove(plt, removed_files)
    Plt.Command.plt_add(plt, added_files)
    Plt.Command.plt_check(plt)

    Plt.Manifest.update()
  end
end
