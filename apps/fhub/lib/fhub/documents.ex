defmodule Fhub.Documents do
  alias Fhub.Documents.Document
  alias Fhub.Documents.Decimal
  alias Fhub.Documents.Json
  alias Fhub.Documents.String

  use Fhub.AccessControl.Context, for: Document
  use Fhub.AccessControl.Context, for: Decimal
  use Fhub.AccessControl.Context, for: Json
  use Fhub.AccessControl.Context, for: String
end
