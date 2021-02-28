defmodule Fsigex.Extensions do
  @callback extensions() :: list(bitstring())
  @callback signatures() :: list(bitstring())
  @callback mime() :: bitstring()
end

defmodule Fsigex.Extensions.GIF do
  @behaviour Fsigex.Extensions
  def extensions, do: [".gif"]

  def signatures,
    do: [
      <<0x47, 0x49, 0x46, 0x38, 0x37, 0x61>>,
      <<0x47, 0x49, 0x46, 0x38, 0x39, 0x61>>
    ]

  def mime, do: "image/gif"
end

defmodule Fsigex.Extensions.PNG do
  @behaviour Fsigex.Extensions
  def extensions, do: [".png"]
  def signatures, do: [<<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>]
  def mime, do: "image/png"
end

defmodule Fsigex.Extensions.JPEG do
  @behaviour Fsigex.Extensions
  def extensions, do: [".jpeg", ".jpg"]
  def signatures, do: [<<0xFF, 0xD8, 0xFF>>]
  def mime, do: "image/jpg"
end

defmodule Fsigex.Extensions.TIFF do
  @behaviour Fsigex.Extensions
  def extensions, do: [".tiff", ".tif"]
  def signatures, do: [<<0x49, 0x49, 0x2A, 0x00>>]
  def mime, do: "image/tiff"
end
