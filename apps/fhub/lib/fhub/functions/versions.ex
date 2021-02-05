defmodule Fhub.Functions.Versions do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "funtions_versions" do
    belongs_to :function, Fhub.Functions.Function, on_replace: :mark_as_invalid

    field :version, :integer
    field :code, :string
    field :compiled_function, EctoTerm

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
  end
end
