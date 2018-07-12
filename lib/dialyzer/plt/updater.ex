defmodule Dialyzer.Plt.Updater do
  alias Dialyzer.{Config, Plt}

  @doc """
  It updates the project plt by analyzing the manifest file,
  and updating only the applications that really changed.
  """
  @spec update(Config.t()) :: :ok
  def update(config) do
    changes = Plt.Manifest.changes(config)
    plt = Plt.Path.project_plt()

    removed_files = changes[:files][:removed] ++ changes[:files][:changed]
    added_files = changes[:files][:changed] ++ changes[:files][:added]

    Plt.Command.remove(plt, removed_files)
    Plt.Command.add(plt, added_files)
    Plt.Command.check(plt)

    Plt.Manifest.update()
  end
end
