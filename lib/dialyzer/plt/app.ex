defmodule Dialyzer.Plt.App do
  defstruct [:app, :mods, :files, :vsn]

  alias Dialyzer.Plt.App

  @type t :: %App{}

  @spec info(atom) :: t | nil
  def info(app) do
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
