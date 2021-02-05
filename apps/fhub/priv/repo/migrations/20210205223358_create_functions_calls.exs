defmodule Fhub.Repo.Migrations.CreateFunctionsCalls do
  use Ecto.Migration

  def change do
    create table(:functions_calls, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :opts, :map
      add :result, :binary

      add :function_version_id, references(:functions_versions, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:functions_calls, [:function_version_id])
  end
end
