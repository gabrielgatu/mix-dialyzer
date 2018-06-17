defmodule Dialyzer.Plt.App do
  defstruct [:app, :mods, :vsn]

  alias Dialyzer.Plt.App

  @type t :: %App{}

  @doc """
  It returns informations, like modules defined,
  files location and current version, of an application.

  Returns nil if the application doesn't exist.
  """
  @spec get_info(atom, boolean) :: t | nil
  def info(app), do: get_info(app, true)
  def info(app, use_cached_version), do: get_info(app, use_cached_version)

  @doc """
  It returns all the filepaths of the modules passed.
  It discards modules which give an error when loading.
  """
  @spec files([atom]) :: list
  def files(mods) do
    Enum.reduce(mods, [], fn mod, acc ->
      case :code.which(mod) do
        status when is_atom(status) -> acc
        filepath -> [filepath | acc]
      end
    end)
  end

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
