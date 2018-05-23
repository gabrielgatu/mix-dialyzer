defmodule Dialyzer.Plt do
  alias Dialyzer.{Config, Plt}
  require Logger

  defstruct [:name, :path, :apps]

  @type t :: %Plt{}

  @doc """
  Ensures the plts used by this project are already built and
  up to date. It builds them and updates them in case this is not true.
  """
  @spec ensure_loaded(Config.t()) :: none
  def ensure_loaded(_config) do
    # TODO: Refactor all this by getting directly from manifest the plt status
    # and switching based on the status (:missing, :outdated, :up_to_date).
    ensure_plt_created()

    if not Plt.Manifest.up_to_date?() do
      Logger.info("Updating plt since it's outdated")
      Plt.Updater.update()
    end
  end

  # Checks that the 3 plts exists. If not, it generates again
  # all 3 of them.
  @spec ensure_plt_created() :: none
  defp ensure_plt_created do
    [
      Plt.Path.generate_erlang_plt_path(),
      Plt.Path.generate_elixir_plt_path(),
      Plt.Path.generate_deps_plt_path()
    ]
    |> Enum.all?(&File.exists?/1)
    |> unless do
         Logger.info("Creating plts for the first time")
         Plt.Builder.build()
         Plt.Manifest.update()
       end
  end
end
