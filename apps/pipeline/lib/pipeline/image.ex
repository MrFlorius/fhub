defmodule Pipeline.Image do
  @exts [".gif", ".png", ".jpeg", ".jpg", ".tiff"]

  def validate_image(%{binary: _b, filename: fname} = state) do
    if Path.extname(fname) in @exts do
      {:ok, state}
    else
      {:error, :validate_image, state, :not_an_image}
    end
  end

  def put_type(%{filename: fname} = state) do
    case Path.extname(fname) do
      "" ->
        {:error, :put_type, state, :no_extension}
      x ->
        {:ok, Map.put(state, :type, String.slice(x, 1..-1))}
    end
  end
end
