defmodule Fhub.Functions.Call do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id

  @derive [Fhub.Resources.ResourceProtocol]

  schema "functions_calls" do
    belongs_to :resource, Fhub.Resources.Resource,
    primary_key: true,
    foreign_key: :id,
    define_field: false,
    on_replace: :mark_as_invalid

    field :opts, :map
    field :result, EctoTerm

    timestamps()
  end

  @doc false
  def changeset(call, attrs) do
    call
    |> cast(attrs, [:opts, :result])
    |> validate_required([:opts])
  end
end
