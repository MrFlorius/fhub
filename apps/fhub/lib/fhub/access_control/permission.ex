defmodule Fhub.AccessControl.Permission do
  use Ecto.Schema
  use Arbor.Tree
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "permissions" do
    field :can, {:array, :string}

    belongs_to :actor, Fhub.Resources.Resource
    belongs_to :parent, __MODULE__
    belongs_to :resource, Fhub.Resources.Resource

    timestamps()
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:can])
    |> validate_required([:can])
  end
end
