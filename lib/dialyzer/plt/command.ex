defmodule Dialyzer.Plt.Command do
  require Logger

  @spec new(binary) :: none
  def new(plt_path) do
    Logger.info("Creating #{Path.basename(plt_path)}")

    plt_path = to_charlist(plt_path)
    run(analysis_type: :plt_build, output_plt: plt_path, apps: [:erts])
  end

  @spec copy(binary, binary) :: none
  def copy(plt_path, new_plt_path) do
    Logger.info("Copying #{Path.basename(plt_path)} to #{Path.basename(new_plt_path)}")
    File.cp!(plt_path, new_plt_path)
  end

  @spec add(binary, [binary]) :: none
  def add(plt_path, files) do
    Logger.info("Adding modules to #{Path.basename(plt_path)}")

    plt_path = to_charlist(plt_path)
    files = Enum.map(files, &to_charlist/1)
    run(analysis_type: :plt_add, init_plt: plt_path, files: files)
  end

  @spec remove(binary, [binary]) :: none
  def remove(plt_path, files) do
    Logger.info("Removing modules from #{Path.basename(plt_path)}")

    plt_path = to_charlist(plt_path)
    files = Enum.map(files, &to_charlist/1)
    run(analysis_type: :plt_remove, init_plt: plt_path, files: files)
  end

  @spec check(binary) :: none
  def check(plt_path) do
    Logger.info("Checking modules in #{Path.basename(plt_path)}")

    plt_path = to_charlist(plt_path)
    run(analysis_type: :plt_check, init_plt: plt_path)
  end

  @spec run(Keyword.t()) :: none
  def run(opts) do
    try do
      :dialyzer.run([check_plt: false] ++ opts)
    catch
      {:dialyzer_error, msg} ->
        Logger.error(":dialyzer.run error: #{msg}")
    end
  end
end
