defimpl Fhub.Resources.ResourceProtocol, for: Fhub.Resources.Resource do
  alias Fhub.Resources.Resource

  @spec resource(Fhub.Resources.Resource.t()) :: Fhub.Resources.Resource.t()
  def resource(%Resource{} = r), do: r
end

defimpl Fhub.Resources.ResourceProtocol, for: Any do
  alias Fhub.Resources.Resource
  alias Fhub.Repo

  def resource(%{resource: %Resource{} = r}), do: r
  def resource(%{__struct__: _} = r) do
    r
    |> Repo.preload(:resource)
    |> Map.get(:resource)
  end

  defmacro __deriving__(module, struct, options) do
    res = Keyword.get(options, :resource_field, :resource)
    quote do
      defimpl Fhub.Resources.ResourceProtocol, for: unquote(module) do
        alias Fhub.Resources.Resource
        alias Fhub.Repo

        def resource(%{unquote(res) => %Resource{} = r}), do: r
        def resource(%{__struct__: unquote(struct.__struct__)} = r) do
          r
          |> Repo.preload(unquote(res))
          |> Map.get(unquote(res))
        end
      end
    end
  end
end
