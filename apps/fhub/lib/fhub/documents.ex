defmodule Fhub.Documents do
  alias Fhub.Apps.App
  alias Fhub.Documents.Document
  alias Fhub.Documents.Decimal
  alias Fhub.Documents.Json
  alias Fhub.Documents.String

  use Fhub.AccessControl.Context, for: Document
  use Fhub.AccessControl.Context, for: Decimal
  use Fhub.AccessControl.Context, for: Json
  use Fhub.AccessControl.Context, for: String

  def create_document(attrs, actor, %Document{} = parent), do: super(attrs, actor, parent)
  def create_document(attrs, actor, %App{} = parent), do: super(attrs, actor, parent)

  def create_decimal(attrs, actor, %Document{} = parent), do: super(attrs, actor, parent)
  def create_string(attrs, actor, %Document{} = parent), do: super(attrs, actor, parent)
  def create_json(attrs, actor, %Document{} = parent), do: super(attrs, actor, parent)
end
