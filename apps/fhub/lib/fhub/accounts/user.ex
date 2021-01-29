defmodule Fhub.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  @derive [Fhub.Resources.ResourceProtocol, Fhub.Resources.TreeProtocol]

  schema "users" do
    belongs_to :resource, Fhub.Resources.Resource,
      [primary_key: true,
      foreign_key: :id,
      define_field: false,
      on_replace: :mark_as_invalid,
      defaults: {Fhub.Resources, :get_resource_for_schema, [%{name: "accounts"}]}]

    field :email, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
    |> cast_assoc(:resource, with: &Fhub.Resources.Resource.changeset/2)
  end
end
