defmodule Fhub.Resources.Path do
  @type t :: [{:id | :name, bitstring()} | bitstring()]
  @spec reduce_to_names(t) :: {nil | bitstring(), [bitstring()]}

  def reduce_to_names(path) when is_list(path) do
    if Keyword.keyword?(path) do
      {id, names} =
        Enum.reduce(path, {nil, []}, fn
          {:id, id}, _ -> {id, []}
          {:name, n}, {id, names} -> {id, [n | names]}
          n, {id, names} -> {id, [n | names]}
        end)

      {id, Enum.reverse(names)}
    else
      {nil, path}
    end
  end
end
