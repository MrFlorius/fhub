defmodule Fhub.AccessControl.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  schema "permissions" do
    belongs_to :resource, Fhub.Resources.Resource, primary_key: true, foreign_key: :id, define_field: false, on_replace: :mark_as_invalid

    field :can, {:array, :string}
    many_to_many :actors, Fhub.Resources.Resource, join_through: "permission_actors"

    timestamps()
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:can])
    |> validate_required([:can])
    |> cast_assoc(:resource, with: &Fhub.Resources.Resource.changeset/2)
  end
end
