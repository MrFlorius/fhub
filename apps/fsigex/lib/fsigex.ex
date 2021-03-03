defmodule Fsigex do
  def by_binary_signature(binary) do
    r =
      extensions()
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
      extensions()
      |> Enum.filter(fn x ->
        x.extensions()
        |> Enum.any?(fn e -> e == extname end)
      end)

    case r do
      [] -> {:error, :not_defined}
      [x] -> {:ok, x}
    end
  end

  def by_mime(mime) do
    case Enum.filter(extensions(), fn x -> x.mime() == mime end) do
      [] -> {:error, :not_defined}
      [x] -> {:ok, x}
    end
  end

  def extensions do
    {:consolidated, m} = Fsigex.Extensions.Protocol.__protocol__(:impls)

    m
  end
end
