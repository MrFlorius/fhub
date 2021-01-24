defprotocol Fhub.Resources.TreeProtocol do
  @moduledoc """
  Provides functions for working with resource and its decendants as tree-like structure
  All functions should return same type as its first argument
  """

  @spec tree_branch(any) :: any
  def tree_branch(resource)

  @spec ancestors(any, boolean()) :: list()
  def ancestors(resource, include \\ false)

  @spec descendants(any, any) :: list()
  def descendants(resource, include \\ false)

  @spec parent(any) :: any
  def parent(resource)

  @spec children(any) :: [list()]
  def children(resource)
end
