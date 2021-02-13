defmodule Fhub.Documents do
  alias Fhub.Resources
  alias Fhub.Resources.Resource
  alias Fhub.Apps.App
  alias Fhub.Documents.Document
  alias Fhub.Documents.Decimal
  alias Fhub.Documents.Json
  alias Fhub.Documents.String

  use Fhub.AccessControl.Context, for: Document
  use Fhub.AccessControl.Context, for: Decimal
  use Fhub.AccessControl.Context, for: Json
  use Fhub.AccessControl.Context, for: String

  def list_children(r) do
    r
    |> Fhub.Resources.Tree.children()
    |> Enum.map(&Fhub.Resources.ResourceProtocol.convert/1)
  end

  def create_document(attrs, actor, %Document{} = parent), do: super(attrs, actor, parent)
  def create_document(attrs, actor, %App{} = parent), do: super(attrs, actor, parent)

  def create_decimal(attrs, actor, %Document{} = parent), do: super(attrs, actor, parent)
  def create_string(attrs, actor, %Document{} = parent), do: super(attrs, actor, parent)
  def create_json(attrs, actor, %Document{} = parent), do: super(attrs, actor, parent)

  def document_schema(%Document{} = d) do
    d
    |> Resources.Tree.descendants(true)
    |> convert_to_document()
  end

  defp convert_to_document([]), do: nil

  defp convert_to_document(%Resource{} = r) do
    Resources.ResourceProtocol.Fhub.Documents.Document.convert(r, Fhub.Repo)
  end

  defp convert_to_document(resource_list) when is_list(resource_list) do
    resource_list
    |> Enum.map(&convert_to_document/1)
    |> Enum.filter(fn
      nil -> false
      [] -> true
      _ -> true
    end)
  end
end
