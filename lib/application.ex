defmodule Dialyzer.Application do
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: Dialyzer.Plt.App.Cache,
        start: {Dialyzer.Plt.App.Cache, :start_link, [[]]}
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
