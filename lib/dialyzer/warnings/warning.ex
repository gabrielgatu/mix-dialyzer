defmodule Dialyzer.Warning do
  defstruct [:name, :file, :line, :message, :tag]
  alias __MODULE__

  @type t :: %__MODULE__{}

  @spec new({atom, {binary, integer}, binary}) :: t
  def new({name, {file, line}, message}) do
    %Warning{name: name, file: file, line: line, message: message}
  end
end
