defimpl Fhub.Resources.ResourceProtocol, for: Fhub.Resources.Resource do
  alias Fhub.Resources.Resource

  @spec resource(Fhub.Resources.Resource.t(), Ecto.Repo.t()) :: Fhub.Resources.Resource.t()
  def resource(%Resource{} = r, _), do: r

  def preload(%Resource{} = r, _), do: r
end

defimpl Fhub.Resources.ResourceProtocol, for: Any do
  alias Fhub.Resources.Resource

  def resource(%{resource: %Resource{} = r}, _), do: r
  def resource(%{__struct__: _} = r, repo) do
    r
    |> preload(repo)
    |> Map.get(:resource)
  end

  def preload(%{__struct__: _} = r, repo) do
    repo.preload(r, :resource)
  end

  defmacro __deriving__(module, struct, options) do
    res = Keyword.get(options, :resource_field, :resource)
    quote do
      defimpl Fhub.Resources.ResourceProtocol, for: unquote(module) do
        alias Fhub.Resources.Resource

        def resource(%{unquote(res) => %Resource{} = r}, _), do: r
        def resource(%{__struct__: unquote(struct.__struct__)} = r, repo) do
          r
          |> preload(repo)
          |> Map.get(unquote(res))
        end

        def preload(%{__struct__: unquote(struct.__struct__)} = r, repo) do
          repo.preload(r, unquote(res))
        end
      end
    end
  end
end
