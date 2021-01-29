defimpl Fhub.Resources.TreeProtocol, for: Any do
  alias Fhub.Resources.Resource
  alias Fhub.Resources.ResourceProtocol

  def tree_branch(r, repo),
    do:
      ancestors(r, false, repo) ++
        [ResourceProtocol.resource(r, repo)] ++ descendants(r, false, repo)

  def ancestors(r, include, repo) do
    resource = ResourceProtocol.resource(r)

    b =
      resource
      |> Resource.ancestors()
      |> repo.all()

    if include, do: b ++ [resource], else: b
  end

  def descendants(r, include, repo) do
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
      # {[], _} ->
      #   r

      {descendants, non_descendants} ->
        [r, Enum.map(descendants, fn x -> tree_like(x, non_descendants) end)]
    end
  end

  def parent(r, repo) do
    ResourceProtocol.resource(r)
    |> Resource.parent()
    |> repo.one()
  end

  def children(r, repo) do
    ResourceProtocol.resource(r)
    |> Resource.children()
    |> repo.all()
  end
end
