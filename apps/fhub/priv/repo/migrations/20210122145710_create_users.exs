defmodule Fhub.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, references(:resources, on_delete: :delete_all, type: :binary_id), primary_key: true
      add :email, :string
      add :name, :string

      timestamps()
    end
  end
end
