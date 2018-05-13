defmodule Dialyzer.Config do
  defstruct check_plt: false, init_plt: nil, files_rec: nil, warnings: []

  alias Dialyzer.{CommandLine, Project, Plt}
  alias __MODULE__

  @type t :: %__MODULE__{}
  @default_warnings [:unmatched_returns, :error_handling, :underspecs, :unknown]

  @spec new(CommandLine.Config.t()) :: Config.t()
  def new(%CommandLine.Config{} = config) do
    init_plt = Plt.generate_deps_plt_path()
    files_rec = Project.build_paths()

    %Config{
      check_plt: false,
      init_plt: init_plt,
      files_rec: files_rec,
      warnings: @default_warnings
    }
  end

  @spec to_erlang_format(Config.t()) :: map
  def to_erlang_format(config) do
    [
      check_plt: config.check_plt,
      init_plt: config.init_plt |> String.to_charlist(),
      files_rec: config.files_rec |> Enum.map(&String.to_charlist/1),
      warnings: config.warnings
    ]
  end
end
