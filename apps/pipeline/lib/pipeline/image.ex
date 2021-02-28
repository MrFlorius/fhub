defmodule Pipeline.Image do
  @exts [Fsigex.Extensions.GIF, Fsigex.Extensions.JPEG, Fsigex.Extensions.PNG, Fsigex.Extensions.TIFF]
  def validate_image(%{binary: binary, filename: fname} = state) do
    with {:ok, ext} when ext in @exts <- Fsigex.by_filename(fname),
         {:ok, sign} <- Fsigex.by_binary_signature(binary),
         {:ok, :match} <- signature_match_extension(ext, sign) do
      {:ok, state}
    else
      {:error, :not_defined} ->
        {:error, :validate_image, state, :bad_signature}

      {:error, :signature_extension_mismatch} ->
        {:error, :validate_image, state, :signature_extension_mismatch}

      {:error, s} when is_bitstring(s) ->
        {:error, :validate_image, state, :bad_extension}
    end
  end

  def put_type(%{filename: f} = state) do
    case Fsigex.by_filename(f) do
      {:error, _} ->
        {:error, :put_type, state, :bad_extension}

      {:ok, ext} ->
        {:ok, Map.put(state, :type, ext)}
    end
  end


  @spec signature_match_extension?(any, any) :: boolean
  def signature_match_extension?(extension, signature), do: extension == signature

  def signature_match_extension(extension, signature) do
    if signature_match_extension?(extension, signature) do
      {:ok, :match}
    else
      {:error, :signature_extension_mismatch}
    end
  end
end
