defmodule Fhub.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files, primary_key: false) do
      add :id, references(:resources, on_delete: :delete_all, type: :binary_id), primary_key: true

      add :name, :string
      add :path, :string

      timestamps()
    end
  end
end
