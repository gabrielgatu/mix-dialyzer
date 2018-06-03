defmodule Dialyzer.Test.Util do
  def create_temporary_project do
    name = random_string(10)
    path = Path.join(System.tmp_dir(), name)
    if File.exists?(path), do: File.rm_rf!(path)
    System.cmd("mix", ["new", path])

    {name, path}
  end

  defp random_string(length) do
    alphabet =
      ?a..?z
      |> Enum.into([])
      |> to_string()
      |> String.codepoints()

    Enum.reduce(1..length, [], fn _i, acc -> [Enum.random(alphabet) | acc] end)
    |> Enum.join()
  end
end
