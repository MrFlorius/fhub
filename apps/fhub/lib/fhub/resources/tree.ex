defmodule Fhub.Resources.Tree do
  alias Fhub.Resources.Resource
  alias Fhub.Resources.ResourceProtocol

  # TODO: re-implemnt tree_branch

  def ancestors(r, include \\ false, repo \\ Fhub.Repo) do
    resource = ResourceProtocol.resource(r)

    b =
      resource
      |> Resource.ancestors()
      |> repo.all()

    if include, do: b ++ [resource], else: b
  end

  # TODO: split in two functions
  def descendants(r, include \\ false, repo \\ Fhub.Repo) do
    resource = ResourceProtocol.resource(r)

    b =
      resource
      |> Resource.descendants()
      |> repo.all()

    if include do
      tree_like(resource, b)
    else
      {^r, descs} = tree_like(resource, b)
      descs
    end
  end

  defp tree_like(r, list) do
    case Enum.split_with(list, fn %{parent_id: pid} -> pid == r.id end) do
      {descendants, non_descendants} ->
        {r, Enum.map(descendants, fn x -> tree_like(x, non_descendants) end)}
    end
  end

  def parent(r, repo \\ Fhub.Repo) do
    r
    |> ResourceProtocol.resource()
    |> Resource.parent()
    |> repo.one()
  end

  def children(r, repo \\ Fhub.Repo) do
    r
    |> ResourceProtocol.resource()
    |> Resource.children()
    |> repo.all()
  end

  def roots(repo \\ Fhub.Repo) do
    Resource.roots()
    |> repo.all()
  end
end
