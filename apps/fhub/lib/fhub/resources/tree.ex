defmodule Fhub.Resources.Tree do
  alias Fhub.Resources.Resource
  alias Fhub.Resources.ResourceProtocol

  def tree_branch(r, repo \\ Fhub.Repo),
    do:
      ancestors(r, false, repo) ++
        [ResourceProtocol.resource(r, repo)] ++ descendants(r, false, repo)

  def ancestors(r, include, repo \\ Fhub.Repo) do
    resource = ResourceProtocol.resource(r)

    b =
      resource
      |> Resource.ancestors()
      |> repo.all()

    if include, do: b ++ [resource], else: b
  end

  def descendants(r, include \\ false, repo \\ Fhub.Repo) do
    resource = ResourceProtocol.resource(r)

    b =
      resource
      |> Resource.descendants()
      |> repo.all()

    if include do
      tree_like(resource, b)
    else
      [^r, descs] = tree_like(resource, b)
      descs
    end
  end

  defp tree_like(r, list) do
    case Enum.split_with(list, fn %{parent_id: pid} -> pid == r.id end) do
      {descendants, non_descendants} ->
        [r, Enum.map(descendants, fn x -> tree_like(x, non_descendants) end)]
    end
  end

  def parent(r, repo \\ Fhub.Repo) do
    ResourceProtocol.resource(r)
    |> Resource.parent()
    |> repo.one()
  end

  def children(r, repo \\ Fhub.Repo) do
    ResourceProtocol.resource(r)
    |> Resource.children()
    |> repo.all()
  end
end
