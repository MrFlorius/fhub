defmodule Fhub.Repo.Migrations.CreateApps do
  use Ecto.Migration

  def change do
    create table(:apps, primary_key: false) do
      add :id, references(:resources, on_delete: :delete_all, type: :binary_id), primary_key: true

      add :name, :string
      add :active, :boolean, default: true

      timestamps()
    end
  end
end
