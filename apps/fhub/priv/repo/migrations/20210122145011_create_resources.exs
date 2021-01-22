defmodule Fhub.Repo.Migrations.CreateResources do
  use Ecto.Migration

  def change do
    create table(:resources, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :deleted, :boolean

      add :parent_id, references(:resources, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:resources, [:parent_id])
  end
end
