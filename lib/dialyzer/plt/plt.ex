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
  def ensure_loaded(config) do
    case Plt.Manifest.status(config) do
      :up_to_date ->
        Logger.info("Plt's are all up to date")

      :outdated ->
        Logger.info("Updating outdated plts")
        Plt.Updater.update(config)

      :missing ->
        Logger.info("Creating plts for the first time")
        Plt.Builder.build(config)
        Plt.Manifest.update()
    end
  end

  @spec plts_exists?() :: boolean
  def plts_exists? do
    [
      Plt.Path.generate_erlang_plt_path(),
      Plt.Path.generate_elixir_plt_path(),
      Plt.Path.generate_deps_plt_path()
    ]
    |> Enum.all?(&File.exists?/1)
  end
end
