defmodule Dialyzer.Warning do
  @moduledoc """
  It represents a dialyzer warning. When taking the original warning,
  it takes also care of setting eventually default values.
  """

  defstruct [:type, :file, :line, :name, :args]
  alias __MODULE__

  @type t :: %__MODULE__{}

  @spec new({atom, {binary, integer}, {atom, list}}) :: t
  def new({type, {file, line}, {name, args}}) do
    file = if file != '', do: file, else: :code.which(elem(args, 0))
    %Warning{type: type, file: to_string(file), line: line, name: name, args: args}
  end

  @doc """
  It returns a tuple, from the original dialyzer warning, that can
  be used to ignore the specific warning, through `.dialyzer.exs`.
  """
  @spec to_ignore_format(t) :: {String.t(), integer, atom}
  def to_ignore_format(warning) do
    file = if warning.file == "", do: :*, else: warning.file
    line = if warning.line == 0, do: :*, else: warning.line
    name = warning.name

    {file, line, name}
  end
end
