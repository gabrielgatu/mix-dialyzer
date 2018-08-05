defmodule Dialyzer.Plt.Command do
  @moduledoc """
  Utility module containing all the necessary functions to
  interact with a plt.

  It takes care of logging to the user the operations
  running, and converting to erlang types the parameters
  (for example, erlang expects charlists instead of elixir strings).
  """

  import Dialyzer.Logger

  @doc """
  It creates a new plt basic plt inside the path passed.
  """
  @spec new(binary) :: {:ok, list} | {:error, any}
  def new(plt_path) do
    info("Creating #{Path.basename(plt_path)}")

    plt_path = to_charlist(plt_path)
    run(analysis_type: :plt_build, output_plt: plt_path, apps: [:erts])
  end

  @doc """
  It duplicates a plt by copying it from one path to another one.
  """
  @spec copy(binary, binary) :: :ok
  def copy(plt_path, new_plt_path) do
    info("Copying #{Path.basename(plt_path)} to #{Path.basename(new_plt_path)}")
    File.cp!(plt_path, new_plt_path)
  end

  @doc """
  It adds the files to the plt, without checking.
  """
  @spec add(binary, [binary]) :: {:ok, list} | {:error, any}
  def add(plt_path, files) do
    if Enum.count(files) > 0 do
      info("Adding modules to #{Path.basename(plt_path)}")

      plt_path = to_charlist(plt_path)
      files = Enum.map(files, &to_charlist/1)
      run(analysis_type: :plt_add, init_plt: plt_path, output_plt: plt_path, files: files)
    end
  end

  @doc """
  It removes the files from the plt, without checking.
  """
  @spec remove(binary, [binary]) :: {:ok, list} | {:error, any}
  def remove(plt_path, files) do
    if Enum.count(files) > 0 do
      info("Removing modules from #{Path.basename(plt_path)}")

      plt_path = to_charlist(plt_path)
      files = Enum.map(files, &to_charlist/1)
      run(analysis_type: :plt_remove, init_plt: plt_path, output_plt: plt_path, files: files)
    end
  end

  @doc """
  It used dialyzer to check the plt.
  """
  @spec check(binary) :: {:ok, list} | {:error, any}
  def check(plt_path) do
    info("Checking modules in #{Path.basename(plt_path)}")

    plt_path = to_charlist(plt_path)
    run(analysis_type: :plt_check, init_plt: plt_path)
  end

  @doc """
  It runs dialyzer with the arguments passed.
  """
  @spec run(Keyword.t()) :: {:ok, list} | {:error, any}
  def run(opts) do
    try do
      res = :dialyzer.run([check_plt: false] ++ opts)
      {:ok, res}
    catch
      {:dialyzer_error, msg} ->
        # TODO: when creating a plt without an app, this logs an error.
        # suppress for now, but remember to handle this case.
        error(":dialyzer.run error: #{msg}")
        {:error, msg}
    end
  end
end
