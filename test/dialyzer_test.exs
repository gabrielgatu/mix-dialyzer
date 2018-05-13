defmodule DialyzerTest do
  use ExUnit.Case
  doctest Dialyzer

  test "greets the world" do
    assert Dialyzer.hello() == :world
  end
end
