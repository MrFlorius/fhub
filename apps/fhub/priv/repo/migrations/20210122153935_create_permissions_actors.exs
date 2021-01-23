defmodule Fhub.Repo.Migrations.CreatePermissionsActors do
  use Ecto.Migration

  def change do
    create table(:permissions_actors, primary_key: false) do
      add :permission_id, references(:permissions, on_delete: :delete_all, type: :binary_id)
      add :resource_id, references(:resources, on_delete: :delete_all, type: :binary_id)
      
    end

    create index(:permissions_actors, [:permission_id])
    create index(:permissions_actors, [:resource_id])

    create unique_index(:permissions_actors, [:permission_id, :resource_id])
  end
end
