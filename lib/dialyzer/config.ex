defmodule Dialyzer.Config do
  defstruct [
    :init_plt,
    build_dir: [],
    warnings: [active: [], ignore: []],
    apps: [remove: [], include: []],
    cmd: nil
  ]

  import Dialyzer.Logger
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
    config = load_config_file()
    %Config{config | cmd: %CommandLine.Config{}}
  end

  @spec load(CommandLine.Config.t()) :: Config.t()
  def load(cmd_config) do
    config = load_config_file()
    %Config{config | cmd: cmd_config}
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
        info("Dialyzer: configuration file not found. Creating it right now: .dialyzer.exs")

        content = create_base_config()
        create_config_file(content)
        read_config_file(content)
    end
  end

  @spec read_config_file(binary) :: t
  defp read_config_file(content) do
    init_plt = Plt.Path.project_plt()
    build_dir = content[:extra_build_dir] ++ Project.build_paths()

    active_warnings = content[:warnings][:active]
    ignored_warnings = content[:warnings][:ignore]

    remove_apps = content[:apps][:remove]
    included_apps = content[:apps][:include]

    %Config{
      init_plt: init_plt,
      build_dir: build_dir,
      warnings: [
        active: active_warnings,
        ignore: ignored_warnings
      ],
      apps: [
        remove: remove_apps,
        include: included_apps
      ]
    }
  end

  @spec create_base_config() :: Keyword.t()
  defp create_base_config do
    warnings = default_warnings()

    [
      apps: [
        remove: [],
        include: []
      ],
      warnings: [
        ignore: [],
        active: warnings
      ],
      extra_build_dir: []
    ]
  end

  @spec create_config_file(Keyword.t()) :: none
  defp create_config_file(content) do
    path()
    |> File.write!(
      inspect(
        content,
        pretty: true,
        width: 0,
        limit: :infinity,
        printable_limit: :infinity,
        pretty: true
      )
    )
  end

  @spec to_erlang_format(Config.t()) :: map
  def to_erlang_format(config) do
    [
      init_plt: config.init_plt |> String.to_charlist(),
      files_rec: config.build_dir |> Enum.map(&String.to_charlist/1),
      warnings: config.warnings[:active]
    ]
  end
end
