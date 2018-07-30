defmodule Dialyzer.Plt do
  alias Dialyzer.{Config, Plt}
  import Dialyzer.Logger

  defstruct [:name, :path, :apps]

  @type t :: %Plt{}

  @doc """
  Ensures the plts used by this project are already built and
  up to date. It builds them and updates them in case this is not true.
  """
  @spec ensure_loaded(Config.t()) :: :ok
  def ensure_loaded(config) do
    case Plt.Manifest.status(config) do
      :up_to_date ->
        info("Plt's are all up to date.")
        :ok

      :outdated ->
        info("Updating outdated plts.")
        Plt.Updater.update(config)
        :ok

      :missing ->
        info("Creating one or more missing plt.")
        Plt.Builder.build(config)
        Plt.Manifest.update()
        :ok
    end
  end

  @doc """
  It returns which plts are missing, that need to be built.
  """
  @spec missing_plts() :: [atom]
  def missing_plts do
    cond do
      not File.exists?(Plt.Path.erlang_plt()) -> [:erlang, :elixir, :project]
      not File.exists?(Plt.Path.elixir_plt()) -> [:elixir, :project]
      not File.exists?(Plt.Path.project_plt()) -> [:project]
      true -> []
    end
  end
end
