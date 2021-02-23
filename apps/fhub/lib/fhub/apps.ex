defmodule Fhub.Apps do
  alias Fhub.Apps.App
  alias Fhub.Resources.Resource
  alias Fhub.Functions.Function
  alias Fhub.Documents.Document
  alias Fhub.AccessControl.Transactions

  import Ecto.Query

  use Fhub.AccessControl.Context, for: App

  # TODO: Enforce unique Apps names
  def update_app(app = %App{}, attrs, actor) do
    transaction = fn repo, _ ->
      app
      |> repo.preload([:resource])
      |> change_app_update(attrs)
      |> (fn c ->
            %{name: name} = Ecto.Changeset.apply_changes(c)
            %{resource: %{id: id, parent_id: parent_id}} = app

            cast_resource_for_app(c, %{id: id, parent_id: parent_id, name: name})
          end).()
      |> repo.update()
    end

    Fhub.AccessControl.Transactions.operation(transaction, actor, :update)
  end

  def build_resource_for_app(parent, _actor, changeset) do
    %{name: name} = Ecto.Changeset.apply_changes(changeset)
    r = Fhub.Resources.ResourceProtocol.resource(parent)

    %{parent_id: r.id, name: name}
  end

  def list_functions(%App{} = app, actor) do
    q =
      from f in Function,
        join: r in Resource,
        on: r.id == f.id,
        where: r.parent_id == ^app.id,
        select: f

    Transactions.operation_filter(fn repo, _ -> {:ok, repo.all(q)} end, actor, :read)
  end

  def list_documents(%App{} = app, actor) do
    q =
      from d in Document,
        join: r in Resource,
        on: r.id == d.id,
        where: r.parent_id == ^app.id,
        select: d

    Transactions.operation_filter(fn repo, _ -> {:ok, repo.all(q)} end, actor, :read)
  end
end
