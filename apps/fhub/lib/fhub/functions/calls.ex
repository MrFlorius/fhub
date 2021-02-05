defmodule Fhub.Functions.Calls do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "functions_calls" do
    belongs_to :version, Fhub.Functions.Versions, on_replace: :mark_as_invalid

    field :opts, :map
    field :result, EctoTerm

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
  end
end
