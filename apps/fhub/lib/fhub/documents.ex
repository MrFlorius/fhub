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

  # TODO: enforce unique documents names(keys)

  def list_documents(%App{} = app, actor) do
    Fhub.Apps.list_documents(app, actor)
  end

  def list_documents(%Document{} = doc, actor) do
    q =
      from d in Document,
        join: r in Resource,
        on: r.id == d.id,
        where: r.parent_id == ^doc.id,
        select: d

    Transactions.operation_filter(fn repo, _ -> {:ok, repo.all(q)} end, actor, :read)
  end

  def document_schema(doc_or_app, actor) do
    Fhub.Repo.transaction(fn ->
      {:ok, docs} = list_documents(doc_or_app, actor)

      %{
        parent: doc_or_app,
        children:
          Enum.map(docs, fn d ->
            {:ok, docs} = list_documents(d, actor)

            %{parent: d, children: docs}
          end)
      }
    end)
  end

  def create_document(attrs, actor, %Document{} = parent), do: super(attrs, actor, parent)
  def create_document(attrs, actor, %App{} = parent), do: super(attrs, actor, parent)

  def create_decimal(attrs, actor, %Document{} = parent), do: super(attrs, actor, parent)
  def create_string(attrs, actor, %Document{} = parent), do: super(attrs, actor, parent)
  def create_json(attrs, actor, %Document{} = parent), do: super(attrs, actor, parent)

  def build_resource_for_document(parent, actor, changeset) do
    name = Ecto.Changeset.apply_changes(changeset).key

    parent
    |> super(actor, changeset)
    |> Map.put(:name, name)
  end
end
