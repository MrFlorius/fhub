defmodule Fhub.Repo.Migrations.CreateDecimals do
  use Ecto.Migration

  def change do
    create table(:decimals, primary_key: false) do
      add :id, references(:resources, on_delete: :delete_all, type: :binary_id), primary_key: true

      add :name, :string
      add :value, :decimal

      timestamps()
    end
  end
end
