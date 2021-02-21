defmodule Fhub.Repo.Migrations.CreateFunctions do
  use Ecto.Migration

  def change do
    create table(:functions, primary_key: false) do
      add :id, references(:resources, on_delete: :delete_all, type: :binary_id), primary_key: true

      add :name, :string

      timestamps()
    end
  end
end
