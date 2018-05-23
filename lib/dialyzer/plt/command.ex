defmodule Dialyzer.Plt.Command do
  require Logger

  @spec plt_new(binary) :: none
  def plt_new(plt_path) do
    Logger.info("Creating #{Path.basename(plt_path)}")

    plt_path = to_charlist(plt_path)
    plt_run(analysis_type: :plt_build, output_plt: plt_path, apps: [:erts])
  end

  @spec plt_copy(binary, binary) :: none
  def plt_copy(plt_path, new_plt_path) do
    Logger.info("Copying #{Path.basename(plt_path)} to #{Path.basename(new_plt_path)}")
    File.cp!(plt_path, new_plt_path)
  end

  @spec plt_add(binary, [binary]) :: none
  def plt_add(plt_path, files) do
    Logger.info("Adding modules to #{Path.basename(plt_path)}")

    plt_path = to_charlist(plt_path)
    files = Enum.map(files, &to_charlist/1)
    plt_run(analysis_type: :plt_add, init_plt: plt_path, files: files)
  end

  @spec plt_remove(binary, [binary]) :: none
  def plt_remove(plt_path, files) do
    Logger.info("Removing modules from #{Path.basename(plt_path)}")

    plt_path = to_charlist(plt_path)
    files = Enum.map(files, &to_charlist/1)
    plt_run(analysis_type: :plt_remove, init_plt: plt_path, files: files)
  end

  @spec plt_check(binary) :: none
  def plt_check(plt_path) do
    Logger.info("Checking modules in #{Path.basename(plt_path)}")

    plt_path = to_charlist(plt_path)
    plt_run(analysis_type: :plt_check, init_plt: plt_path)
  end

  @spec plt_run(Keyword.t()) :: none
  def plt_run(opts) do
    try do
      :dialyzer.run([check_plt: false] ++ opts)
    catch
      {:dialyzer_error, msg} ->
        IO.puts(":dialyzer.run error: #{msg}")
    end
  end
end
