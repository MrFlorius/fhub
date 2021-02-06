defmodule Fhub.Functions.Versions do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "functions_versions" do
    belongs_to :function, Fhub.Functions.Function, on_replace: :mark_as_invalid

    field :version, :integer
    field :code, :string
    field :compiled_function, EctoTerm

    has_many :calls, Fhub.Functions.Calls, foreign_key: :version_id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:version, :code, :compiled_function])
    |> validate_required([:version, :code])
  end
end
