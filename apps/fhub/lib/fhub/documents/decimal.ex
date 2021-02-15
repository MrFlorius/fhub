defmodule Fhub.Documents.Decimal do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  @derive [Fhub.Resources.ResourceProtocol]

  schema "decimals" do
    belongs_to :resource, Fhub.Resources.Resource,
      primary_key: true,
      foreign_key: :id,
      define_field: false,
      on_replace: :mark_as_invalid

    field :key, :string
    field :value, :decimal

    timestamps()
  end

  @doc false
  def changeset(decimal, attrs) do
    decimal
    |> cast(attrs, [:key, :value])
    |> validate_required([:key, :value])
  end
end
