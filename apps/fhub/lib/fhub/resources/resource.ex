defmodule Fhub.Resources.Resource do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "resources" do
    field :domain, {:array, :string}
    field :deleted, :boolean

    many_to_many :permissions, Fhub.AccessControl.Permission, join_through: "permission_actors"

    timestamps()
  end

  @doc false
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, [:domain])
    |> validate_required([:domain])
  end
end
