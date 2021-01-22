defmodule Fhub.Repo.Migrations.CreatePermissions do
  use Ecto.Migration

  def change do
    create table(:permissions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :can, {:array, :string}
      add :actor_id, references(:resources, on_delete: :nothing, type: :binary_id)
      add :parent_id, references(:permissions, on_delete: :nothing, type: :binary_id)
      add :resource_id, references(:resources, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:permissions, [:actor_id])
    create index(:permissions, [:parent_id])
    create index(:permissions, [:resource_id])
  end
end
