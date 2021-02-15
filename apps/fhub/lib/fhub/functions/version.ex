defmodule Fhub.Functions.Version do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  @derive [Fhub.Resources.ResourceProtocol]

  schema "functions_versions" do
    belongs_to :resource, Fhub.Resources.Resource,
      primary_key: true,
      foreign_key: :id,
      define_field: false,
      on_replace: :mark_as_invalid

    field :version, :integer
    field :code, :string
    field :compiled_function, EctoTerm

    timestamps()
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:version, :code, :compiled_function])
    |> validate_required([:version, :code])
  end
end
