defmodule Dialyzer.Plt.App do
  defstruct [:app, :mods, :files, :vsn]

  alias Dialyzer.Plt.App

  @type t :: %App{}

  @spec get_info(atom, boolean) :: t | nil
  def info(app), do: get_info(app, true)
  def info(app, use_cached_version), do: get_info(app, use_cached_version)

  @spec get_info(atom, boolean) :: t | nil
  defp get_info(app, true) do
    App.Cache.get_or_insert(app)
  end

  @spec get_info(atom, boolean) :: t | nil
  defp get_info(app, false) do
    case can_load_app?(app) do
      false ->
        nil

      true ->
        app
        |> read_app_info()
        |> find_beam_files()
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
  defp read_app_info(app) do
    info = Application.spec(app)
    mods = info[:modules]
    vsn = info[:vsn]
    %App{app: app, mods: mods, vsn: vsn}
  end

  @spec find_beam_files(t) :: t
  defp find_beam_files(app) do
    Enum.reduce(app.mods, app, fn mod, app ->
      mod
      |> Atom.to_charlist()
      |> Kernel.++('.beam')
      |> :code.where_is_file()
      |> case do
        path when is_list(path) ->
          path = Path.expand(path)
          files = app.files || []
          %App{app | files: [path | files]}

        :non_existing ->
          app
      end
    end)
  end
end

defmodule Dialyzer.Plt.App.Cache do
  use Agent

  def start_link(_) do
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
