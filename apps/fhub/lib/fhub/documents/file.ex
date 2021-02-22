defmodule Fhub.Documents.File do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  @derive [Fhub.Resources.ResourceProtocol]

  schema "files" do
    belongs_to :resource, Fhub.Resources.Resource,
      primary_key: true,
      foreign_key: :id,
      define_field: false,
      on_replace: :mark_as_invalid

    field :name, :string
    field :file, Fhub.Documents.File.Uploader.Type

    timestamps()
  end

  def changeset(file, attrs) do
    file
    |> cast(attrs, [:name])
    |> cast_attachments(attrs, [:file])
    |> validate_required([:name, :file])
  end
end
