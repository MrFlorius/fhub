defmodule Fhub.Repo.Migrations.CreateResources do
  use Ecto.Migration

  def change do
    create table(:resources, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :deleted, :boolean

      timestamps()
    end

  end
end
