defmodule Fhub.Repo.Migrations.CreatePermissionActor do
  use Ecto.Migration

  def change do
    create table(:permissions_actors, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :permission_id, references(:permissions, on_delete: :delete_all, type: :binary_id)
      add :actor_id, references(:resources, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:permissions_actors, [:permission_id, :actor_id])
  end
end
