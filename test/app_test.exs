defmodule Dialyzer.Plt.AppTest do
  use ExUnit.Case
  alias Dialyzer.Plt.{App}

  setup_all do
    Application.ensure_started(:mix_dialyzer)
    :ok
  end

  describe "when getting application info" do
    test "it works correctly when the application exists" do
      info = App.info(:elixir)
      info2 = Application.spec(:elixir)

      assert info.app == elem(info2[:mod], 0)
      assert info.mods == info2[:modules]
      assert info.vsn == info2[:vsn]
    end

    test "it returns nil when application doesn't exist" do
      assert App.info(:not_existing) == nil
    end

    test "it caches the result" do
      app = :kernel

      refute App.Cache.in_cache?(app)
      App.info(app)
      assert App.Cache.in_cache?(app)
    end
  end
end
