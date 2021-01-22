defmodule Fhub.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :name, :string

    belongs_to :resource, Fhub.Resources.Resource

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name])
    |> cast_assoc(:resource, with: &Fhub.Resources.Resource.changeset/2)
    |> validate_required([:email, :name])
  end
end
