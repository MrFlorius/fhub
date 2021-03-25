defmodule Fsigex do
  @spec by_binary_signature(any) :: {:error, :not_defined} | {:ok, any}
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

  @spec by_filename(bitstring) :: {:error, :not_defined} | {:ok, any}
  def by_filename(filename), do: by_extname(Path.extname(filename))

  @spec by_extname(bitstring) :: {:error, :not_defined} | {:ok, any}
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

  @spec by_mime(bitstring) :: {:error, :not_defined} | {:ok, any}
  def by_mime(mime) do
    case Enum.filter(extensions(), fn x -> x.mime() == mime end) do
      [] -> {:error, :not_defined}
      [x] -> {:ok, x}
    end
  end

  defp extensions do
    {:consolidated, m} = Fsigex.Extensions.Protocol.__protocol__(:impls)

    m
  end
end
