defmodule Dialyzer.Plt.Updater do
  @moduledoc """
  This module is responsable for updating a plt, based on the changes
  found by the manifest file.
  """

  alias Dialyzer.{Config, Plt}

  @doc """
  It updates the project plt by analyzing the manifest file,
  and updating only the applications that really changed.
  """
  @spec update(Config.t()) :: :ok
  def update(config) do
    changes = Plt.Manifest.changes(config)
    plt = Plt.Path.project_plt()

    _ = Plt.Command.remove(plt, changes[:files][:removed])
    _ = Plt.Command.add(plt, changes[:files][:added])

    Plt.Manifest.update()
  end
end
