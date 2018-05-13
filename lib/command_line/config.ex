defmodule Dialyzer.CommandLine.Config do
  defstruct []

  alias __MODULE__

  @type t :: %__MODULE__{}
  @command_options []

  def parse(args) do
    {opts, _, _} = OptionParser.parse(args, strict: @command_options)
    %Config{}
  end
end
