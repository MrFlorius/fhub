defmodule Fhub.Repo.Migrations.CreateStrings do
  use Ecto.Migration

  def change do
    create table(:strings, primary_key: false) do
      add :id, references(:resources, on_delete: :delete_all, type: :binary_id), primary_key: true

      add :name, :string
      add :value, :string

      timestamps()
    end
  end
end
