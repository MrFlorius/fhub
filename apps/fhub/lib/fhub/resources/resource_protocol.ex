defprotocol Fhub.Resources.ResourceProtocol do
  @moduledoc """
  Provides functions for working with resource and its decendants as tree-like structure
  All functions returns resources
  """
  @spec resource(any) :: Fhub.Resources.Resource.t()
  def resource(term, repo \\ Fhub.Repo)

  def preload(term, repo \\ Fhub.Repo)
end
