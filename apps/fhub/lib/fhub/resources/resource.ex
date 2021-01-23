defmodule Fhub.Resources.Resource do
  use Ecto.Schema
  use Arbor.Tree
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "resources" do
    field :name, :string, default: nil

    belongs_to :parent, __MODULE__

    has_many :permissions, Fhub.AccessControl.Permission
    many_to_many :permissions_as_actor, Fhub.AccessControl.Permission, join_through: "permissions_actors"

    timestamps()
  end

  @doc false
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [:name, :parent_id])
    |> cast_assoc(:parent, with: &changeset/2)
    |> validate_required([])
  end
end
