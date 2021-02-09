defmodule Fhub.Apps do
  alias Fhub.Apps.App
  alias Fhub.Resources.Resource
  alias Fhub.Functions.Function
  alias Fhub.Documents.Document
  alias Fhub.AccessControl.Transactions

  import Ecto.Query

  use Fhub.AccessControl.Context, for: App, resource_parent: "apps"

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

  # def list_caches(%App{} = app, actor) do

  # end
end
