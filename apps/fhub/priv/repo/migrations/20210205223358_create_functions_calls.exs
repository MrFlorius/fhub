defmodule Fhub.Repo.Migrations.CreateFunctionsCalls do
  use Ecto.Migration

  def change do
    create table(:functions_calls, primary_key: false) do
      add :id, references(:resources, on_delete: :delete_all, type: :binary_id), primary_key: true

      add :opts, :map
      add :result, :binary

      timestamps()
    end
  end
end
