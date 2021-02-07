defmodule Fhub.Repo.Migrations.CreateFunctionsVersions do
  use Ecto.Migration

  def change do
    create table(:functions_versions, primary_key: false) do
      add :id, references(:resources, on_delete: :delete_all, type: :binary_id), primary_key: true

      add :version, :integer
      add :code, :text
      add :compiled_function, :binary

      timestamps()
    end
  end
end
