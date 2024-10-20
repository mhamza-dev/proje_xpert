defmodule ProjeXpert.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :name, :string
      add :created_by_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:channels, [:created_by_id])
    create unique_index(:channels, [:name, :created_by_id])
  end
end
