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

    "erlang-#{otp_version}_elixir-#{elixir_version}_deps-#{build_env}"
    |> build_plt_abs_path()
    |> Path.expand()
  end

  @spec generate_elixir_plt_path() :: binary
  def generate_elixir_plt_path() do
    build_plt_abs_path("erlang-#{get_otp_version()}_elixir-#{System.version()}")
  end

  @spec generate_erlang_plt_path() :: binary
  def generate_erlang_plt_path(), do: build_plt_abs_path("erlang-" <> get_otp_version())

  @spec get_otp_version() :: String.t()
  defp get_otp_version() do
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

  @spec build_plt_abs_path(String.t()) :: binary
  defp build_plt_abs_path(name) do
    build_path = Mix.Project.build_path()
    plt_name = "dialyzer_#{name}.plt"

    Path.join(build_path, plt_name)
  end
end
