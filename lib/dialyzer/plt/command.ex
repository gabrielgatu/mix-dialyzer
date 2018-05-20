defmodule Dialyzer.Plt.Command do
  def plt_new(plt_path) do
    info("Creating #{Path.basename(plt_path)}")

    plt_path = path_to_erlang_format(plt_path)
    plt_run(analysis_type: :plt_build, output_plt: plt_path, apps: [:erts])
    :ok
  end

  def plt_copy(plt_path, new_plt_path) do
    info("Copying #{Path.basename(plt_path)} to #{Path.basename(new_plt_path)}")
    File.cp!(plt_path, new_plt_path)
  end

  def plt_add(plt_path, files) do
    case Enum.count(files) do
      0 ->
        :ok

      n ->
        info("Adding #{n} modules to #{Path.basename(plt_path)}")

        plt_path = path_to_erlang_format(plt_path)
        files = Enum.map(files, &path_to_erlang_format/1)
        plt_run(analysis_type: :plt_add, init_plt: plt_path, files: files)
        :ok
    end
  end

  def plt_remove(plt_path, files) do
    case Enum.count(files) do
      0 ->
        :ok

      n ->
        info("Removing #{n} modules from #{Path.basename(plt_path)}")

        plt_path = path_to_erlang_format(plt_path)
        files = Enum.map(files, &path_to_erlang_format/1)
        plt_run(analysis_type: :plt_remove, init_plt: plt_path, files: files)
        :ok
    end
  end

  def plt_check(plt_path, files) do
    case Enum.count(files) do
      0 ->
        :ok

      n ->
        info("Checking #{n} modules in #{Path.basename(plt_path)}")

        plt_path = path_to_erlang_format(plt_path)
        plt_run(analysis_type: :plt_check, init_plt: plt_path)
        :ok
    end
  end

  def plt_run(opts) do
    try do
      :dialyzer.run([check_plt: false] ++ opts)
    catch
      {:dialyzer_error, msg} ->
        IO.puts(":dialyzer.run error: #{msg}")
    end
  end

  defp path_to_erlang_format(path) when is_bitstring(path) do
    encoding = :file.native_name_encoding()
    :unicode.characters_to_list(path, encoding)
  end

  defp info(msg), do: apply(Mix.shell(), :info, [msg])
end
