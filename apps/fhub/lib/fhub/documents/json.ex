defmodule Fhub.Documents.Json do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  @derive [Fhub.Resources.ResourceProtocol]

  schema "jsons" do
    belongs_to :resource, Fhub.Resources.Resource,
      primary_key: true,
      foreign_key: :id,
      define_field: false,
      on_replace: :mark_as_invalid

    field :name, :string
    field :value, :map

    timestamps()
  end

  def changeset(json, attrs) do
    json
    |> cast(attrs, [:name, :value])
    |> validate_required([:name, :value])
  end
end
