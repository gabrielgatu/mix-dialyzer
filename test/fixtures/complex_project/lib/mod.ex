defmodule ComplexProject.Mod do
  def add(n1, n2), do: n1 + n2
  def mult(n1, n2), do: n1 * n2

  def call_add, do: add("hello", "world")
  def call_mult, do: mult("hello", "world")
end
