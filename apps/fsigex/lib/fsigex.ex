defmodule Fsigex do
  alias Fsigex.Extensions.{GIF, JPEG, PNG, TIFF}

  # TODO: Research if there is a way to add all submodule automatically
  @modules [GIF, JPEG, PNG, TIFF]

  def by_binary_signature(binary) do
    r =
      @modules
      |> Enum.filter(fn x ->
        x.signatures()
        |> Enum.any?(fn p -> String.starts_with?(binary, p) end)
      end)

    case r do
      [] -> {:error, :not_defined}
      [x] -> {:ok, x}
    end
  end

  def by_filename(filename), do: by_extname(Path.extname(filename))

  def by_extname(extname) do
    r =
      @modules
      |> Enum.filter(fn x ->
        x.extensions()
        |> Enum.any?(fn e -> e == extname end)
      end)

    case r do
      [] -> {:error, :not_found}
      [x] -> {:ok, x}
    end
  end

  def by_mime(mime) do
    case Enum.filter(@modules, fn x -> x.mime() == mime end) do
      [] -> {:error, :not_found}
      [x] -> {:ok, x}
    end
  end
end
