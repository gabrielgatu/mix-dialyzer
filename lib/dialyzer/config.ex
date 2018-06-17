defmodule Dialyzer.Config do
  defstruct [:init_plt, build_dir: [], warnings: [], apps: [remove: [], include: []]]
  require Logger

  alias Dialyzer.{CommandLine, Project, Plt}
  alias __MODULE__

  @type t :: %__MODULE__{}

  @doc """
  It loads and (if not already present), creates the
  configuration file with the default options inferred
  from the project enviroment.
  """
  @spec load() :: Config.t()
  def load() do
    load_config_file()
  end

  @spec load(CommandLine.Config.t()) :: Config.t()
  def load(_cmd_config) do
    load_config_file()
  end

  @doc """
  It returns the absolute path of the configuration file.
  """
  @spec path :: binary
  def path do
    File.cwd!() |> Path.join("/.dialyzer.exs")
  end

  @doc """
  It returns the default warnings used for an analysis.
  """
  @spec default_warnings :: [atom]
  def default_warnings do
    [
      :unmatched_returns,
      :error_handling,
      :underspecs,
      :unknown
    ]
  end

  @spec load_config_file() :: t
  defp load_config_file do
    path()
    |> File.read()
    |> case do
      {:ok, content} ->
        content
        |> Code.eval_string()
        |> elem(0)
        |> read_config_file()

      {:error, _} ->
        Logger.info(
          "Dialyzer: configuration file not found. Creating it right now at .dialyzer.exs"
        )

        content = create_base_config()
        create_config_file(content)
        read_config_file(content)
    end
  end

  @spec read_config_file(binary) :: t
  defp read_config_file(content) do
    init_plt = Plt.Path.project_plt()
    build_dir = content[:extra_build_dir] ++ Project.build_paths()
    warnings = content[:warnings]
    remove_apps = content[:apps][:remove]
    include_apps = content[:apps][:include]

    %Config{
      init_plt: init_plt,
      build_dir: build_dir,
      warnings: warnings,
      apps: [
        remove: remove_apps,
        include: include_apps
      ]
    }
  end

  @spec create_base_config() :: Keyword.t()
  defp create_base_config do
    warnings = default_warnings()

    [
      warnings: warnings,
      apps: [
        remove: [],
        include: []
      ],
      extra_build_dir: []
    ]
  end

  @spec create_config_file(Keyword.t()) :: none
  defp create_config_file(content) do
    path()
    |> File.write!(inspect(content, limit: :infinity, printable_limit: :infinity, pretty: true))
  end

  @spec to_erlang_format(Config.t()) :: map
  def to_erlang_format(config) do
    [
      init_plt: config.init_plt |> String.to_charlist(),
      files_rec: config.build_dir |> Enum.map(&String.to_charlist/1),
      warnings: config.warnings
    ]
  end
end
