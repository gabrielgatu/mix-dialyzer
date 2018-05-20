defmodule Dialyzer.Plt do
  alias Dialyzer.{Config, Project, Plt, Plt.App}
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

      changes = Plt.Manifest.changes()
      plt = generate_deps_plt_path()

      removed_files = Enum.flat_map(changes[:apps][:removed] ++ changes[:apps][:changed], &(&1.files))
      added_files = Enum.flat_map(changes[:apps][:changed] ++ changes[:apps][:added], &(&1.files))

      Plt.Command.plt_remove(plt, removed_files)
      Plt.Command.plt_add(plt, added_files)
      Plt.Command.plt_check(plt, added_files)

      Plt.Manifest.update()
    end
  end

  @doc """
  Generates an absolute path for the project plt (going to include the elixir version,
  erlang, and deps). The path is referring to a location inside the build dir of the project,
  since the plt is going to be saved there.
  """
  @spec generate_deps_plt_path() :: binary
  def generate_deps_plt_path() do
    otp_version = get_otp_version()
    elixir_version = System.version()
    build_env = get_build_env_tag()

    "erlang-#{otp_version}_elixir-#{elixir_version}_deps-#{build_env}"
    |> build_plt_abs_path()
    |> Path.expand()
  end

  # Checks that the 3 plts exists. If not, it generates again
  # all 3 of them.
  @spec ensure_plt_created() ::  none
  defp ensure_plt_created do
    [generate_erlang_plt_path(), generate_elixir_plt_path(), generate_deps_plt_path()]
    |> Enum.all?(&File.exists?/1)
    |> unless do
      Logger.info("Creating plts for the first time")

      Project.dependencies()
      |> Kernel.++([Project.application()])
      |> plts_list()
      |> check_plts()

      Plt.Manifest.update()
    end
  end

  # Generates a list of 3 elements.
  # The first element referes to the erlang plt,
  # the second element referes to the elixir plt and
  # the third element referes to the project level plt.
  @spec plts_list([atom]) :: [t]
  defp plts_list(apps) do
    erlang_apps = [:erts, :kernel, :stdlib, :crypto]
    elixir_apps = [:elixir] ++ erlang_apps
    project_apps = apps ++ elixir_apps

    [
      %Plt{
        name: :erlang,
        path: generate_erlang_plt_path(),
        apps: Enum.map(erlang_apps, &App.info/1)
      },
      %Plt{
        name: :elixir,
        path: generate_elixir_plt_path(),
        apps: Enum.map(elixir_apps, &App.info/1)
      },
      %Plt{
        name: :project,
        path: generate_deps_plt_path(),
        apps: Enum.map(project_apps, &App.info/1)
      }
    ]
  end

  defp check_plts(plts), do: check_plts(plts, nil)
  defp check_plts([], _), do: nil

  @spec check_plts([t], t | nil) :: none
  defp check_plts([plt | rest], nil) do
    plt_files = MapSet.new(Enum.reduce(plt.apps, [], fn app, acc -> app.files ++ acc end))

    Plt.Command.plt_new(plt.path)
    Plt.Command.plt_add(plt.path, plt_files)
    Plt.Command.plt_check(plt.path, plt_files)

    check_plts(rest, plt)
  end

  defp check_plts([plt | rest], prev_plt) do
    Plt.Command.plt_copy(prev_plt.path, plt.path)

    plt_files = MapSet.new(Enum.reduce(plt.apps, [], fn app, acc -> app.files ++ acc end))

    prev_plt_files =
      MapSet.new(Enum.reduce(prev_plt.apps, [], fn app, acc -> app.files ++ acc end))

    remove = MapSet.difference(prev_plt_files, plt_files)
    add = MapSet.difference(plt_files, prev_plt_files)
    check = MapSet.intersection(plt_files, prev_plt_files)

    Plt.Command.plt_remove(plt.path, remove)
    Plt.Command.plt_add(plt.path, add)
    Plt.Command.plt_check(plt.path, check)

    check_plts(rest, plt)
  end

  @spec generate_elixir_plt_path() :: binary
  defp generate_elixir_plt_path() do
    build_plt_abs_path("erlang-#{get_otp_version()}_elixir-#{System.version()}")
  end

  @spec generate_erlang_plt_path() :: binary
  defp generate_erlang_plt_path(), do: build_plt_abs_path("erlang-" <> get_otp_version())

  @spec get_otp_version() :: String.t()
  defp get_otp_version() do
    major = :erlang.system_info(:otp_release) |> List.to_string()
    version_file = Path.join([:code.root_dir(), "releases", major, "OTP_VERSION"])

    try do
      version_file
      |> File.read!()
      |> String.split("\n", trim: true)
    else
      [full] -> full
      _ -> major
    catch
      :error, _ -> major
    end
  end

  @spec get_build_env_tag() :: String.t()
  defp get_build_env_tag() do
    Mix.Project.config()
    |> Keyword.fetch!(:build_per_environment)
    |> case do
         true -> Atom.to_string(Mix.env())
         false -> "shared"
       end
  end

  @spec build_plt_abs_path(String.t()) :: binary
  defp build_plt_abs_path(name) do
    build_path = Mix.Project.build_path()
    plt_name = "dialyzer_#{name}.plt"

    Path.join(build_path, plt_name)
  end
end
