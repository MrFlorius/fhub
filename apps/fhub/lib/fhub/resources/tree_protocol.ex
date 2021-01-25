defprotocol Fhub.Resources.TreeProtocol do
  @moduledoc """
  Provides functions for working with resource and its decendants as tree-like structure
  """

  @spec tree_branch(any, Ecto.Repo.t()) :: Fhub.Resources.Resource.t()
  def tree_branch(resource, repo \\ Fhub.Repo)

  @spec ancestors(any, boolean(), Ecto.Repo.t()) :: [Fhub.Resources.Resource.t()]
  def ancestors(resource, include \\ false, repo \\ Fhub.Repo)

  @spec descendants(any, any, Ecto.Repo.t()) :: [Fhub.Resources.Resource.t()]
  def descendants(resource, include \\ false, repo \\ Fhub.Repo)

  @spec parent(any, Ecto.Repo.t()) :: Fhub.Resources.Resource.t()
  def parent(resource, repo \\ Fhub.Repo)

  @spec children(any, Ecto.Repo.t()) :: [Fhub.Resources.Resource.t()]
  def children(resource, repo \\ Fhub.Repo)
end
