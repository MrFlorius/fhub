defmodule Fhub.Documents.File.Uploader do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  # TODO: Make storage-independent
  def storage_dir(_version, {_file, scope}) do
    "uploads/documents/files/#{scope.id}"
  end

  def file_path(%{file: %{file_name: fname}} = file) do
    Path.join([
      storage_dir_prefix(),
      storage_dir(:original, {file.file, file}),
      fname
    ])
  end

  def file_binary(file) do
    file
    |> file_path()
    |> File.read()
  end

  def remove(file) do
    with :ok <-
           file
           |> file_path()
           |> File.rm(),
         :ok <-
           [storage_dir_prefix(), storage_dir(:original, {file.file, file})]
           |> Path.join()
           |> File.rmdir() do
      :ok
    end
  end
end
