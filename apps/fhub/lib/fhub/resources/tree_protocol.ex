defprotocol Fhub.Resources.TreeProtocol do
  @moduledoc """
  Provides functions for working with resource and its decendants as tree-like structure
  """

  @spec tree_branch(any) :: Fhub.Resources.Resource.t()
  def tree_branch(resource)

  @spec ancestors(any, boolean()) :: [Fhub.Resources.Resource.t()]
  def ancestors(resource, include \\ false)

  @spec descendants(any, any) :: [Fhub.Resources.Resource.t()]
  def descendants(resource, include \\ false)

  @spec parent(any) :: Fhub.Resources.Resource.t()
  def parent(resource)

  @spec children(any) :: [Fhub.Resources.Resource.t()]
  def children(resource)
end
