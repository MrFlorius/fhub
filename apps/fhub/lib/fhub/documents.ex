defmodule Fhub.Documents do
  alias Fhub.Apps.App
  alias Fhub.Resources.Resource
  alias Fhub.Documents.Document
  alias Fhub.Documents.Decimal
  alias Fhub.Documents.Json
  alias Fhub.Documents.String
  alias Fhub.AccessControl.Transactions

  import Ecto.Query

  use Fhub.AccessControl.Context, for: Document
  use Fhub.AccessControl.Context, for: Decimal
  use Fhub.AccessControl.Context, for: Json
  use Fhub.AccessControl.Context, for: String

  # Document
  def list_documents(%App{} = app, actor) do
    Fhub.Apps.list_documents(app, actor)
  end

  def list_documents(%Document{id: id}, actor) do
    q =
      from d in Document,
        join: r in Resource,
        on: r.id == d.id,
        where: r.parent_id == ^id,
        select: d

    Transactions.operation_filter(fn repo, _ -> {:ok, repo.all(q)} end, actor, :read)
  end

  def document_schema(document_or_app, actor) do
    Fhub.Repo.transaction(fn ->
      {:ok, docs} = list_documents(document_or_app, actor)

      %{
        parent: document_or_app,
        children: Enum.map(docs, fn d ->
          case document_schema(d, actor) do
            {:ok, %{parent: p, children: []}} -> p
            {:ok, s} -> s
          end
        end)
      }
    end)
  end

  def document_fields(%Document{} = document, actor) do
    with {:ok, d1} <- list_documents(document, actor),
         {:ok, d2} <- list_decimals(document, actor),
         {:ok, s} <- list_strings(document, actor),
         {:ok, j} <- list_jsons(document, actor) do
      {:ok, d1 ++ d2 ++ s ++ j}
    end
  end

  def build_resource_for_document(parent, actor, changeset),
    do: build_resource(parent, actor, changeset)

  def create_document(attrs, actor, %Document{} = parent), do: super(attrs, actor, parent)
  def create_document(attrs, actor, %App{} = parent), do: super(attrs, actor, parent)

  def update_document(document = %Document{}, attrs, actor),
    do:
      update_for(document, attrs, actor, &change_document_update/2, &cast_resource_for_document/2)

  # Decimal
  def list_decimals(%Document{id: id}, actor) do
    q =
      from d in Decimal,
        join: r in Resource,
        on: r.id == d.id,
        where: r.parent_id == ^id,
        select: d

    Transactions.operation_filter(fn repo, _ -> {:ok, repo.all(q)} end, actor, :read)
  end

  def build_resource_for_decimal(parent, actor, changeset),
    do: build_resource(parent, actor, changeset)

  def create_decimal(attrs, actor, %Document{} = parent), do: super(attrs, actor, parent)

  def update_decimal(decimal = %Decimal{}, attrs, actor),
    do: update_for(decimal, attrs, actor, &change_decimal_update/2, &cast_resource_for_decimal/2)

  # String
  def list_strings(%Document{id: id}, actor) do
    q =
      from s in String,
        join: r in Resource,
        on: r.id == s.id,
        where: r.parent_id == ^id,
        select: s

    Transactions.operation_filter(fn repo, _ -> {:ok, repo.all(q)} end, actor, :read)
  end

  def build_resource_for_string(parent, actor, changeset),
    do: build_resource(parent, actor, changeset)

  def create_string(attrs, actor, %Document{} = parent), do: super(attrs, actor, parent)

  def update_string(string = %String{}, attrs, actor),
    do: update_for(string, attrs, actor, &change_string_update/2, &cast_resource_for_string/2)

  # Json
  def list_jsons(%Document{id: id}, actor) do
    q =
      from j in Json,
        join: r in Resource,
        on: r.id == j.id,
        where: r.parent_id == ^id,
        select: j

    Transactions.operation_filter(fn repo, _ -> {:ok, repo.all(q)} end, actor, :read)
  end

  def build_resource_for_json(parent, actor, changeset),
    do: build_resource(parent, actor, changeset)

  def create_json(attrs, actor, %Document{} = parent), do: super(attrs, actor, parent)

  def update_json(json = %Json{}, attrs, actor),
    do: update_for(json, attrs, actor, &change_json_update/2, &cast_resource_for_json/2)

  # Helpers
  defp update_for(s, attrs, actor, change, cast_resource) do
    transaction = fn repo, _ ->
      s
      |> repo.preload([:resource])
      |> change.(attrs)
      |> (fn c ->
            %{name: name} = Ecto.Changeset.apply_changes(c)
            %{resource: %{id: id, parent_id: parent_id}} = s

            cast_resource.(c, %{id: id, parent_id: parent_id, name: name})
          end).()
      |> repo.update()
    end

    Fhub.AccessControl.Transactions.operation(transaction, actor, :update)
  end

  defp build_resource(parent, _actor, changeset) do
    %{name: name} = Ecto.Changeset.apply_changes(changeset)
    r = Fhub.Resources.ResourceProtocol.resource(parent)

    %{parent_id: r.id, name: name}
  end
end
