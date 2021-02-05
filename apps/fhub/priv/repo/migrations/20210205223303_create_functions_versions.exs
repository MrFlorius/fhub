defmodule Fhub.Repo.Migrations.CreateFunctionsVersions do
  use Ecto.Migration

  def change do
    create table(:functions_versions, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :version, :integer
      add :code, :text
      add :compiled_function, :binary

      add :function_id, references(:functions, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:functions_versions, [:function_id])
  end
end
