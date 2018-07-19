defmodule Dialyzer.Plt.DialyzerTest do
  use ExUnit.Case
  import Dialyzer.Test.Util
  alias Dialyzer.Config

  setup_all do
    Application.ensure_all_started(:mix_dialyzer)
    :ok
  end

  describe "when running dialyzer" do
    test "it prints out the warnings when emitted" do
      in_project(:complex_project, fn ->
        config = Config.load()
        output = Dialyzer.run(config)

        assert String.contains?(output, "lib/mod.ex:5")
      end)
    end

    test "it doesn't print a warning when ignored in .dialyzer.exs" do
      in_project(:complex_project, fn ->
        config = Config.load()
        output = Dialyzer.run(config)

        refute String.contains?(output, "lib/mod.ex:6")
      end)
    end
  end
end
