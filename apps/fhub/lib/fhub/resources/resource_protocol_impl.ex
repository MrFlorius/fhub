defimpl Fhub.Resources.ResourceProtocol, for: Fhub.Resources.Resource do
  alias Fhub.Resources.Resource

  def resource(%Resource{} = r), do: r
end

defimpl Fhub.Resources.ResourceProtocol, for: Any do
  alias Fhub.Resources.Resource

  def resource(%{resource: %Resource{} = r}), do: r
end
