defmodule ProjeXpert.Repo.Migrations.CreateWorkerProjects do
  use Ecto.Migration

  def change do
    create table(:project_workers) do
      add :worker_id, references(:users, on_delete: :delete_all)
      add :project_id, references(:projects, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:project_workers, [:worker_id])
    create index(:project_workers, [:project_id])
    create unique_index(:project_workers, [:project_id, :worker_id])
  end
end
