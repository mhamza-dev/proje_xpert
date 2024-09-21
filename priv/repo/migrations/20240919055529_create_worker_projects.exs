defmodule ProjeXpert.Repo.Migrations.CreateWorkerProjects do
  use Ecto.Migration

  def change do
    create table(:worker_projects) do
      add :worker_id, references(:users, on_delete: :nothing)
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:worker_projects, [:worker_id])
    create index(:worker_projects, [:project_id])
    create unique_index(:worker_projects, [:project_id, :worker_id])
  end
end
