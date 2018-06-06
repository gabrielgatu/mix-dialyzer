defmodule Dialyzer.Plt.Path do
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

    in_build_dir("erlang-#{otp_version}_elixir-#{elixir_version}_deps-#{build_env}")
  end

  @spec generate_elixir_plt_path() :: binary
  def generate_elixir_plt_path() do
    in_home_dir("erlang-#{get_otp_version()}_elixir-#{System.version()}")
  end

  @spec generate_erlang_plt_path() :: binary
  def generate_erlang_plt_path() do
    in_home_dir("erlang-#{get_otp_version()}")
  end

  @spec home_dir() :: binary
  def home_dir do
    Path.join([System.user_home(), ".cache", "dialyzer", "plts"])
  end

  @spec get_otp_version() :: String.t()
  defp get_otp_version do
    "#{System.otp_release()}-erts-#{:erlang.system_info(:version)}"
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

  @spec in_build_dir(String.t()) :: binary
  defp in_build_dir(name) do
    build_path = Mix.Project.build_path()
    plt_name = "dialyzer_#{name}.plt"
    Path.join(build_path, plt_name)
  end

  @spec in_home_dir(String.t()) :: binary
  defp in_home_dir(name) do
    home_path = home_dir()
    plt_name = "dialyzer_#{name}.plt"
    Path.join(home_path, plt_name)
  end
end
