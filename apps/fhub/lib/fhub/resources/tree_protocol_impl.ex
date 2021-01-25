defimpl Fhub.Resources.TreeProtocol, for: Any do
  alias Fhub.Resources.Resource
  alias Fhub.Resources.ResourceProtocol

  def tree_branch(r, repo),
    do: ancestors(r, false, repo) ++ [ResourceProtocol.resource(r, repo)] ++ descendants(r, false, repo)

  def ancestors(r, include, repo) do
    b =
      ResourceProtocol.resource(r)
      |> Resource.ancestors()
      |> repo.all()

    if include, do: b ++ [ResourceProtocol.resource(r)], else: b
  end

  def descendants(r, include, repo) do
    b =
      ResourceProtocol.resource(r)
      |> Resource.descendants()
      |> repo.all()

    if include, do: [ResourceProtocol.resource(r) | b], else: b
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
