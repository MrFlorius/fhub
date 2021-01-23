defmodule Fhub.Resources.Resource do
  use Ecto.Schema
  use Arbor.Tree
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "resources" do
    belongs_to :parent, __MODULE__

    many_to_many :permissions, Fhub.AccessControl.Permission, join_through: "permission_actors"

    timestamps()
  end

  @doc false
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [])
    |> validate_required([])
  end
end
