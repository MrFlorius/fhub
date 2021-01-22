defmodule Fhub.AccessControl.Permission do
  use Ecto.Schema
  use Arbor.Tree
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "permissions" do
    field :can, {:array, :string}

    belongs_to :parent, __MODULE__
    belongs_to :resource, Fhub.Resources.Resource

    many_to_many :actors, Fhub.Resources.Resource, join_through: "permission_actors"

    timestamps()
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:can, :parent_id, :resource_id])
    |> cast_assoc(:resource, with: &Fhub.Resources.Resource.changeset/2)
    |> validate_required([:can])
  end
end
