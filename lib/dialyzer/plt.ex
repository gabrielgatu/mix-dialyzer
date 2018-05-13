defmodule Dialyzer.Plt do
  alias Dialyzer.{Config, Project}

  @spec ensure_loaded(Config.t()) :: none
  def ensure_loaded(_config) do
    apps = Project.dependencies()
    hash = build_dependency_hash(apps)

    if is_plt_up_to_date(hash) do
      info("PLT is up to date!")
    else
      apps
      |> plts_list()
      |> find_plts()
      |> check_plts()

      File.write(generate_deps_plt_hash_path(), hash)
    end
  end

  @spec build_dependency_hash(list()) :: {[atom()], binary()}
  def build_dependency_hash(apps) do
    lock_file = Mix.Dep.Lock.read() |> :erlang.term_to_binary()
    :crypto.hash(:sha, lock_file <> :erlang.term_to_binary(apps))
  end

  # Check if the stored hash is up to date with the newly generated hash
  # by verifying if they have the same content.
  @spec is_plt_up_to_date(binary()) :: boolean()
  defp is_plt_up_to_date(hash) do
    generate_deps_plt_hash_path()
    |> File.read()
    |> case do
         {:ok, stored_hash} -> hash == stored_hash
         _ -> false
       end
  end

  @spec plts_list([atom]) :: [{String.t(), [atom]}]
  def plts_list(deps) do
    elixir_apps = [:elixir]
    erlang_apps = [:erts, :kernel, :stdlib, :crypto]

    core_plts = [
      {generate_elixir_plt_path(), elixir_apps},
      {generate_erlang_plt_path(), erlang_apps}
    ]

    # Instead of []
    [{generate_deps_plt_path(), deps ++ elixir_apps ++ erlang_apps} | core_plts]
  end

  defp find_plts(plts), do: find_plts(plts, [])
  defp find_plts([], acc), do: acc

  defp find_plts([{plt, apps} | plts], acc) do
    plt
    |> files_included_in_plt()
    |> case do
         # Plt file does not exists
         nil ->
           find_plts(plts, [{plt, apps, nil} | acc])

         files ->
           apps_rest = Enum.flat_map(plts, fn {_plt2, apps2} -> apps2 end)
           apps = Enum.uniq(apps ++ apps_rest)
           check_plts([{plt, apps, files} | acc])
       end
  end

  # TODO: Complete typespec
  @spec check_plts([{String.t(), [atom], any()}]) :: any()
  defp check_plts(plts) do
    Enum.reduce(plts, {nil, MapSet.new(), %{}}, fn {plt, apps, beams}, acc ->
      check_plt(plt, apps, beams, acc)
    end)
  end

  defp check_plt(plt, apps, old_beams, {prev_plt, prev_beams, prev_cache}) do
    info("Finding applications for #{Path.basename(plt)}")

    cache = resolve_apps(apps, prev_cache)
    mods = cache_mod_diff(cache, prev_cache)

    info("Finding modules for #{Path.basename(plt)}")

    beams = resolve_modules(mods, prev_beams)
    check_beams(plt, beams, old_beams, prev_plt)
    {plt, beams, cache}
  end

  defp cache_mod_diff(new, old) do
    Enum.flat_map(new, fn {app, {mods, _deps}} ->
      case Map.has_key?(old, app) do
        true -> []
        false -> mods
      end
    end)
  end

  @spec resolve_apps([atom], map) :: map
  defp resolve_apps(apps, cache) do
    apps
    |> Enum.uniq()
    |> Enum.filter(&(not Map.has_key?(cache, &1)))
    |> Enum.map(&app_info/1)
    |> Enum.into(cache)
  end

  # TODO: Complete typespec
  @spec app_info(atom) :: any()
  defp app_info(app) do
    app
    |> Atom.to_charlist()
    |> Kernel.++('.app')
    |> :code.where_is_file()
    |> case do
         :non_existing ->
           error("Unknown application #{inspect(app)}")
           {app, {[], []}}

         app_file ->
           Path.expand(app_file)
           |> read_app_info(app)
       end
  end

  defp read_app_info(app_file, app) do
    app_file
    |> :file.consult()
    |> case do
         {:ok, [{:application, ^app, info}]} ->
           parse_app_info(info, app)

         {:error, reason} ->
           Mix.raise("Could not read #{app_file}: #{:file.format_error(reason)}")
       end
  end

  defp parse_app_info(info, app) do
    mods = Keyword.get(info, :modules, [])
    apps = Keyword.get(info, :applications, [])
    inc_apps = Keyword.get(info, :included_applications, [])
    runtime_deps = get_runtime_deps(info)
    {app, {mods, runtime_deps ++ inc_apps ++ apps}}
  end

  defp get_runtime_deps(info) do
    Keyword.get(info, :runtime_dependencies, [])
    |> Enum.map(&parse_runtime_dep/1)
  end

  defp parse_runtime_dep(runtime_dep) do
    runtime_dep = IO.chardata_to_string(runtime_dep)
    regex = ~r/^(.+)\-\d+(?|\.\d+)*$/
    [app] = Regex.run(regex, runtime_dep, capture: :all_but_first)
    String.to_atom(app)
  end

  # TODO: Complete typespec
  @spec resolve_modules(any(), MapSet.t()) :: any()
  defp resolve_modules(modules, beams) do
    Enum.reduce(modules, beams, &resolve_module/2)
  end

  defp resolve_module(module, beams) do
    beam = Atom.to_charlist(module) ++ '.beam'

    case :code.where_is_file(beam) do
      path when is_list(path) ->
        path = Path.expand(path)
        MapSet.put(beams, path)

      :non_existing ->
        error("Unknown module #{inspect(module)}")
        beams
    end
  end

  defp check_beams(plt, beams, nil, prev_plt) do
    plt_ensure(plt, prev_plt)

    case files_included_in_plt(plt) do
      nil ->
        Mix.raise("Could not open #{plt}: #{:file.format_error(:enoent)}")

      old_beams ->
        check_beams(plt, beams, old_beams)
    end
  end

  defp check_beams(plt, beams, old_beams, _prev_plt) do
    check_beams(plt, beams, old_beams)
  end

  defp check_beams(plt, beams, old_beams) do
    remove = MapSet.difference(old_beams, beams)
    plt_remove(plt, remove)
    check = MapSet.intersection(beams, old_beams)
    plt_check(plt, check)
    add = MapSet.difference(beams, old_beams)
    plt_add(plt, add)
  end

  defp plt_ensure(plt, nil), do: plt_new(plt)
  defp plt_ensure(plt, prev_plt), do: plt_copy(prev_plt, plt)

  defp plt_new(plt) do
    info("Creating #{Path.basename(plt)}")
    plt = to_erlang_format(plt)
    _ = plt_run(analysis_type: :plt_build, output_plt: plt, apps: [:erts])
    :ok
  end

  defp plt_copy(plt, new_plt) do
    info("Copying #{Path.basename(plt)} to #{Path.basename(new_plt)}")
    File.cp!(plt, new_plt)
  end

  defp plt_add(plt, files) do
    case MapSet.size(files) do
      0 ->
        :ok

      n ->
        Mix.shell().info("Adding #{n} modules to #{Path.basename(plt)}")
        plt = to_erlang_format(plt)
        files = erl_files(files)
        _ = plt_run(analysis_type: :plt_add, init_plt: plt, files: files)
        :ok
    end
  end

  defp plt_remove(plt, files) do
    case MapSet.size(files) do
      0 ->
        :ok

      n ->
        info("Removing #{n} modules from #{Path.basename(plt)}")
        plt = to_erlang_format(plt)
        files = erl_files(files)
        _ = plt_run(analysis_type: :plt_remove, init_plt: plt, files: files)
        :ok
    end
  end

  defp plt_check(plt, files) do
    case MapSet.size(files) do
      0 ->
        :ok

      n ->
        Mix.shell().info("Checking #{n} modules in #{Path.basename(plt)}")
        plt = to_erlang_format(plt)
        _ = plt_run(analysis_type: :plt_check, init_plt: plt)
        :ok
    end
  end

  defp plt_run(opts) do
    try do
      :dialyzer.run([check_plt: false] ++ opts)
    catch
      {:dialyzer_error, msg} ->
        IO.puts(":dialyzer.run error: #{msg}")
    end
  end

  defp erl_files(files) do
    Enum.reduce(files, [], &[to_erlang_format(&1) | &2])
  end

  # TODO: How I can specify the erlang spec for return?
  @spec to_erlang_format(String.t()) :: any()
  defp to_erlang_format(path) when is_bitstring(path) do
    encoding = :file.native_name_encoding()
    :unicode.characters_to_list(path, encoding)
  end

  @spec files_included_in_plt(String.t()) :: MapSet.t() | nil
  defp files_included_in_plt(plt) do
    info("Looking up modules in #{Path.basename(plt)}")

    plt
    |> to_erlang_format()
    |> :dialyzer.plt_info()
    |> case do
         {:ok, info} ->
           info
           |> Keyword.fetch!(:files)
           |> Enum.reduce(MapSet.new(), &MapSet.put(&2, Path.expand(&1)))

         {:error, :no_such_file} ->
           nil

         {:error, reason} ->
           Mix.raise("Could not open #{plt}: #{:file.format_error(reason)}")
       end
  end

  @spec generate_elixir_plt_path() :: binary
  def generate_elixir_plt_path() do
    build_plt_abs_path("erlang-#{get_otp_version()}_elixir-#{System.version()}")
  end

  @spec generate_erlang_plt_path() :: binary
  def generate_erlang_plt_path(), do: build_plt_abs_path("erlang-" <> get_otp_version())

  @spec generate_deps_plt_hash_path() :: binary
  defp generate_deps_plt_hash_path, do: generate_deps_plt_path() <> ".hash"

  @spec generate_deps_plt_path() :: binary
  def generate_deps_plt_path() do
    otp_version = get_otp_version()
    elixir_version = System.version()
    build_env = get_build_env_tag()

    "erlang-#{otp_version}_elixir-#{elixir_version}_deps-#{build_env}"
    |> build_plt_abs_path()
    |> Path.expand()
  end

  @spec build_plt_abs_path(String.t()) :: binary
  defp build_plt_abs_path(name) do
    build_path = Mix.Project.build_path()
    plt_name = "dialyzer_#{name}.plt"

    Path.join(build_path, plt_name)
  end

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

  defp info(msg), do: apply(Mix.shell(), :info, [msg])

  defp error(msg), do: apply(Mix.shell(), :error, [msg])
end
