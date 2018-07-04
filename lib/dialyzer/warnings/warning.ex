defmodule Dialyzer.Warning do
  defstruct [:type, :file, :line, :name, :args]
  alias __MODULE__

  @type t :: %__MODULE__{}

  @spec new({atom, {binary, integer}, {atom, list}}) :: t
  def new({type, {file, line}, {name, args}}) do
    %Warning{type: type, file: to_string(file), line: line, name: name, args: args}
  end
end
