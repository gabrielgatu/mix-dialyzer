defmodule Dialyzer.Test.Util do
  def create_temporary_project do
    name = random_string(10)
    path = Path.join(System.tmp_dir(), name)
    if File.exists?(path), do: File.rm_rf!(path)
    System.cmd("mix", ["new", path])

    {name, path}
  end

  def random_string(length) do
    alphabet = ?a..?z |> Enum.to_list()

    Enum.reduce((1..length), [], fn (_i, acc) ->
      [Enum.random(alphabet) | acc]
    end)
    |> to_string()
  end
end
