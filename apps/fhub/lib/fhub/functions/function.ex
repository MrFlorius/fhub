defmodule Fhub.Functions.Function do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  @derive [Fhub.Resources.ResourceProtocol]

  schema "functions" do
    belongs_to :resource, Fhub.Resources.Resource,
      primary_key: true,
      foreign_key: :id,
      define_field: false,
      on_replace: :mark_as_invalid

    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(function, attrs) do
    function
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
