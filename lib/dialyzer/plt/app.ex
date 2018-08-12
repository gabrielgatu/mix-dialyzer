defmodule Dialyzer.Plt.App do
  @moduledoc """
  It represents an OTP application. This is used as a "wrapper",
  to group some informations used internally by `mix_dialyzer`.

  Internally, it implements a caching system, this is because some
  projects depend on the same applications, and we want to speed things up.
  """

  defstruct [:app, :mods, :vsn]

  alias __MODULE__

  @type t :: %App{}

  @doc """
  It returns informations, like modules defined,
  files location and current version, of an application.

  Returns nil if the application doesn't exist.
  """
  @spec get_info(atom, boolean) :: t | nil
  def info(app), do: get_info(app, true)
  def info(app, use_cached_version), do: get_info(app, use_cached_version)

  defp get_info(app, true) do
    App.Cache.get_or_insert(app)
  end

  defp get_info(app, false) do
    case can_load_app?(app) do
      false ->
        nil

      true ->
        app
        |> read_app_info()
    end
  end

  @spec can_load_app?(atom) :: boolean
  defp can_load_app?(app) do
    case Application.load(app) do
      :ok -> true
      {:error, {:already_loaded, _}} -> true
      {:error, _} -> false
    end
  end

  @spec read_app_info(atom) :: t
  def read_app_info(app) do
    info = Application.spec(app)
    vsn = info[:vsn]
    mods =
      info[:modules]
      |> Enum.map(&dependencies/1)
      |> List.flatten()
      |> Enum.uniq()
      |> IO.inspect()
      # |> Enum.map(&App.Module.new/1)

    %App{app: app, mods: mods, vsn: vsn}
  end

  def dependencies(mod), do: dependencies(mod, [])
  def dependencies([], acc), do: acc
  def dependencies(mod, acc) do
    for mod_ref <- module_references(mod),
        mod_ref not in acc do
      IO.inspect(mod)
      dependencies(mod_ref, [mod | acc])
    end
  end

  def module_references(mod) do
    try do
      forms = :forms.read(mod)

      calls =
        :forms.filter(
          fn
            {:call, _, {:remote, _, {:atom, _, _}, _}, _} -> true
            _ -> false
          end,
          forms
        )

      modules = for {:call, _, {:remote, _, {:atom, _, module}, _}, _} <- calls, do: module
      Enum.uniq(modules)
    rescue
      _ -> []
    catch
      _ -> []
    end
  end
end

defmodule Dialyzer.Plt.App.Module do
  @moduledoc """
  It represents a BEAM module. This is used as a "wrapper",
  to group some informations used internally by `mix_dialyzer`.
  """

  defstruct [:module, :filepath, :md5]
  alias __MODULE__

  @type t :: %__MODULE__{}

  @spec new(atom) :: t
  def new(mod) when is_atom(mod) do
    filepath = :code.which(mod)
    md5 = apply(mod, :module_info, [:md5])

    %Module{module: mod, filepath: filepath, md5: md5}
  end
end

defmodule Dialyzer.Plt.App.Cache do
  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get_or_insert(app) do
    Agent.get_and_update(__MODULE__, fn state ->
      {info, new_state} =
        case Map.fetch(state, app) do
          :error ->
            info = Dialyzer.Plt.App.info(app, false)
            {info, Map.put(state, app, info)}

          {:ok, info} ->
            {info, state}
        end

      {info, new_state}
    end)
  end

  def in_cache?(app) do
    Agent.get(__MODULE__, fn state ->
      Map.has_key?(state, app)
    end)
  end
end
