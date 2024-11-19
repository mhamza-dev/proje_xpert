defmodule ProjeXpert.Repo.Migrations.CreateSprints do
  use Ecto.Migration

  def change do
    create table(:sprints) do
      add :title, :string
      add :start_date, :date
      add :end_date, :date
      add :status, :string, default: "pending"
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:sprints, [:project_id])

    alter table(:columns) do
      remove :project_id
      add :sprint_id, references(:sprints, on_delete: :nothing)
    end

    alter table(:tasks) do
      add :sprint_id, references(:sprints, on_delete: :nothing)
    end
  end
end
