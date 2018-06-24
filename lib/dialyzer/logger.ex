defmodule Dialyzer.Logger do
  require Logger

  def info(arg) do
    IO.puts(color(:green, "* - #{arg}"))
  end

  def error(arg) do
    IO.puts(color(:red, "* - #{arg}"))
  end

  def color(:cyan, arg), do: IO.ANSI.format([:cyan, arg], true)
  def color(:yellow, arg), do: IO.ANSI.format([:yellow, arg], true)
  def color(:green, arg), do: IO.ANSI.format([:green, arg], true)
  def color(:red, arg), do: IO.ANSI.format([:red, arg], true)
end
