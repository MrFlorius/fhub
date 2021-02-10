defmodule Fhub.Repo.Migrations.CreateJsons do
  use Ecto.Migration

  def change do
    create table(:jsons, primary_key: false) do
      add :id, references(:resources, on_delete: :delete_all, type: :binary_id), primary_key: true

      add :key, :string
      add :value, :map

      timestamps()
    end
  end
end
