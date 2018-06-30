defmodule Dialyzer.Warnings.Manifest do
  alias Dialyzer.Warning

  @spec cross_update([Warning.t()]) :: [Warning.t()]
  def cross_update(current_warnings) do
    cached_warnings = get_or_create_manifest()

    Enum.map(current_warnings, fn current_warn ->
      case find_cached_warning(cached_warnings, current_warn) do
        nil ->
          tag = generate_tag()
          %Warning{current_warn | tag: tag}

        cached_warn ->
          %Warning{current_warn | tag: cached_warn.tag}
      end
    end)
  end

  @spec save([Warning.t()]) :: none
  def save(warnings) do
    path()
    |> File.write!(inspect(warnings, limit: :infinity, printable_limit: :infinity))
  end

  @spec find_cached_warning([Warning.t()], Warning.t()) :: Warning.t() | nil
  defp find_cached_warning(cached_warnings, warning) do
    Enum.find(cached_warnings, fn cached_warn ->
      cached_warn.name == warning.name and cached_warn.file == warning.file and
        cached_warn.message == warning.message
    end)
  end

  # This should always generate an unique tag, I say "should"
  # because we have 1/26^7 chance to generate the same one.
  @spec generate_tag() :: String.t()
  defp generate_tag do
    for _ <- 0..6, into: "", do: <<Enum.random(?a..?z)>>
  end

  @doc """
  It returns the path for the manifest file.
  """
  @spec path() :: binary
  def path(), do: Dialyzer.Plt.Path.project_plt() <> ".warnings.manifest"

  @spec get_or_create_manifest() :: map
  defp get_or_create_manifest do
    path()
    |> File.read()
    |> case do
      {:ok, content} ->
        content
        |> Code.eval_string()
        |> elem(0)

      {:error, _} ->
        File.write!(path(), inspect(%{}))
        %{}
    end
  end
end
