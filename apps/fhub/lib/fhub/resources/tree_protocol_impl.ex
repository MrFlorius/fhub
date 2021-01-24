defimpl Fhub.Resources.TreeProtocol, for: Any do
  alias Fhub.Repo
  alias Fhub.Resources.Resource
  alias Fhub.Resources.ResourceProtocol

  def tree_branch(r),
    do: ancestors(r) ++ [ResourceProtocol.resource(r)] ++ descendants(r)

  def ancestors(r, include \\ false) do
    b =
      ResourceProtocol.resource(r)
      |> Resource.ancestors()
      |> Repo.all()

    if include, do: b ++ [ResourceProtocol.resource(r)], else: b
  end

  def descendants(r, include \\ false) do
    b =
      ResourceProtocol.resource(r)
      |> Resource.descendants()
      |> Repo.all()

    if include, do: [ResourceProtocol.resource(r) | b], else: b
  end

  def parent(r) do
    ResourceProtocol.resource(r)
    |> Resource.parent()
    |> Repo.one()
  end

  def children(r) do
    ResourceProtocol.resource(r)
    |> Resource.children()
    |> Repo.all()
  end
end
