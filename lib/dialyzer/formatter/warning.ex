defmodule Dialyzer.Warning do
  @moduledoc """
  Behaviour for defining warning semantings.

  Contains callbacks for various warnings
  """

  @doc """
  By expressing the warning that is to be matched on, error handlong
  and dispatching can be avoided in format functions.
  """
  @callback warning() :: atom

  @doc """
  The name of the warning, used to quickly give the user a context.
  """
  @callback name() :: String.t()

  @doc """
  A short message, often missing things like success types and expected types for space.
  """
  @callback format_short([String.t()] | {String.t(), String.t(), String.t()} | String.t()) ::
              String.t()

  @doc """
  The default documentation when seeing an error wihout the user
  otherwise overriding the format.
  """
  @callback format_long([String.t()] | {String.t(), String.t(), String.t()} | String.t()) ::
              String.t()
end