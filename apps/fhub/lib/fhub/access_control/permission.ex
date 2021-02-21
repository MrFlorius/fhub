defmodule Fhub.AccessControl.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "permissions" do
    field :can, {:array, EctoAtom}

    belongs_to :resource, Fhub.Resources.Resource, on_replace: :mark_as_invalid

    many_to_many :actors, Fhub.Resources.Resource,
      on_replace: :delete,
      join_through: "permissions_actors"

    timestamps()
  end

  def access_any, do: :any
  def access_none, do: :none

  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:can, :resource_id])
    |> cast_assoc(:resource, with: &Fhub.Resources.Resource.changeset/2)
    |> validate_required([:can])
  end
end
