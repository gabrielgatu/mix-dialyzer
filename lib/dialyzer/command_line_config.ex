defmodule Dialyzer.CommandLine.Config do
  defstruct msg_type: :short, halt_on_error: false

  alias __MODULE__

  @type t :: %__MODULE__{}
  @command_options [
    long: :boolean,
    ci: :boolean
  ]

  def parse(args) do
    {opts, _, _} = OptionParser.parse(args, strict: @command_options)

    halt_on_error = Keyword.get(opts, :ci, false)
    msg_type =
      case Keyword.fetch(opts, :long) do
        {:ok, true} -> :long
        :error -> :short
      end

    %Config{msg_type: msg_type, halt_on_error: halt_on_error}
  end
end
