defmodule Fhub.Apps.App do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  @derive [Fhub.Resources.ResourceProtocol]

  schema "apps" do
    belongs_to :resource, Fhub.Resources.Resource,
      primary_key: true,
      foreign_key: :id,
      define_field: false,
      on_replace: :mark_as_invalid

    field :name, :string
    field :active, :boolean, default: true

    timestamps()
  end


  def changeset(app, attrs) do
    app
    |> cast(attrs, [:name, :active])
    |> validate_required([:name])
  end
end
