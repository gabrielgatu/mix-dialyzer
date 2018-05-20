defmodule Dialyzer.Plt.App do
  defstruct [:app, :mods, :deps, :files, :vsn]

  alias Dialyzer.Plt.App

  @type t :: %App{}

  @spec info(atom) :: t | nil
  def info(app) do
    app
    |> Atom.to_charlist()
    |> Kernel.++('.app')
    |> :code.where_is_file()
    |> case do
         :non_existing ->
           nil

         app_file ->
           app_file
           |> Path.expand()
           |> read_app_info(app)
           |> find_beam_files()
           |> find_version()
       end
  end

  # TODO: Complete typespec with more accurate list types
  @spec read_app_info(binary, atom) :: t | nil
  defp read_app_info(app_file, app) do
    app_file
    |> :file.consult()
    |> case do
         {:ok, [{:application, ^app, info}]} ->
           parse_app_info(info, app)

         {:error, _reason} ->
           nil
       end
  end

  @spec parse_app_info(Keyword.t(), atom) :: t
  defp parse_app_info(info, app) do
    mods = Keyword.get(info, :modules, [])
    apps = Keyword.get(info, :applications, [])
    included_apps = Keyword.get(info, :included_applications, [])
    runtime_deps = Keyword.get(info, :runtime_dependencies, []) |> Enum.map(&parse_runtime_dep/1)

    %App{app: app, mods: mods, deps: apps ++ included_apps ++ runtime_deps}
  end

  @spec parse_runtime_dep(:unicode.chardata()) :: atom
  defp parse_runtime_dep(runtime_dep) do
    runtime_dep = IO.chardata_to_string(runtime_dep)

    ~r/^(.+)\-\d+(?|\.\d+)*$/
    |> Regex.run(runtime_dep, capture: :all_but_first)
    |> List.first()
    |> String.to_atom()
  end

  # Checks that every module is present into the system.
  # If not, then it discards it.
  defp find_beam_files(nil), do: nil

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

  @spec find_version(t) :: t
  defp find_version(app) do
    vsn = Application.spec(app.app, :vsn)
    %App{app | vsn: vsn}
  end
end
