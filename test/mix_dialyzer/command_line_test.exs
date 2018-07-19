defmodule Dialyzer.Plt.CommandLineTest do
  use ExUnit.Case
  import Dialyzer.Test.Util
  alias Dialyzer.CommandLine.Config

  describe "when passing some arguments to dialyzer" do
    test "it uses the default values when an argument is not specified" do
      config = Config.parse([])
      assert config.msg_type == :short
    end

    test "it parses correctly the arguments" do
      config = Config.parse(["--long"])
      assert config.msg_type == :long
    end

    test "it ignores unsupported arguments" do
      config = Config.parse(["--new_argument"])
      assert config.msg_type == :short
    end
  end
end
