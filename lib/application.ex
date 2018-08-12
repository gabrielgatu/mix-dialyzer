defmodule Dialyzer.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Dialyzer.Plt.App.Cache, []),
      worker(Dialyzer.Project.DepedencyGraph.Cache, [])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
