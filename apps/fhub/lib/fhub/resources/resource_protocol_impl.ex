defimpl Fhub.Resources.ResourceProtocol, for: Fhub.Resources.Resource do
  alias Fhub.Resources.Resource

  @spec resource(Fhub.Resources.Resource.t(), Ecto.Repo.t()) :: Fhub.Resources.Resource.t()
  def resource(%Resource{} = r, _ \\ Fhub.Repo), do: r

  def preload(%Resource{} = r, _ \\ Fhub.Repo), do: r

  def convert(%Resource{} = r, repo \\ Fhub.Repo) do
    {_, impls} = Fhub.Resources.ResourceProtocol.__protocol__(:impls)

    {:ok, x} =
      repo.transaction(fn repo ->
        impls
        |> Enum.map(fn
          Fhub.Resources.Resource -> nil
          impl -> Module.concat(Fhub.Resources.ResourceProtocol, impl).convert(r, repo)
        end)
        |> Enum.find(fn x -> x != nil end)
        |> case do
          nil -> r
          x -> x
        end
      end)

    x
  end
end

defimpl Fhub.Resources.ResourceProtocol, for: Any do
  alias Fhub.Resources.Resource

  def resource(r, repo \\ Fhub.Repo)
  def resource(%{resource: %Resource{} = r}, _), do: r

  def resource(%{__struct__: _} = r, repo) do
    r
    |> preload(repo)
    |> Map.get(:resource)
  end

  def preload(%{__struct__: _} = r, repo \\ Fhub.Repo) do
    repo.preload(r, :resource)
  end

  def convert(_, _ \\ Fhub.Repo), do: :not_implemented

  defmacro __deriving__(module, struct, options) do
    res = Keyword.get(options, :resource_field, :resource)

    quote do
      defimpl Fhub.Resources.ResourceProtocol, for: unquote(module) do
        alias Fhub.Resources.Resource

        def resource(r, repo \\ Fhub.Repo)
        def resource(%{unquote(res) => %Resource{} = r}, _), do: r

        def resource(%{__struct__: unquote(struct.__struct__)} = r, repo) do
          r
          |> preload(repo)
          |> Map.get(unquote(res))
        end

        def preload(%{__struct__: unquote(struct.__struct__)} = r, repo \\ Fhub.Repo) do
          repo.preload(r, unquote(res))
        end

        def convert(%Resource{id: id} = r, repo \\ Fhub.Repo) do
          require Ecto.Query

          Ecto.Query.from(
            e in unquote(module),
            join: r in assoc(e, unquote(res)),
            where: r.id == ^id,
            select: e,
            preload: [unquote(res)]
          )
          |> repo.one()
        end
      end
    end
  end
end
