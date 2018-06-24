defmodule Dialyzer.CommandLine.Config do
  defstruct msg_type: :short

  alias __MODULE__

  @type t :: %__MODULE__{}
  @command_options [
    long: :boolean
  ]

  def parse(args) do
    {opts, _, _} = OptionParser.parse(args, strict: @command_options)

    msg_type =
      case Keyword.fetch(opts, :long) do
        {:ok, true} -> :long
        :error -> :short
      end

    %Config{msg_type: msg_type}
  end
end
