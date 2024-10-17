defmodule ProjeXpert.Repo.Migrations.CreateWorkerTasks do
  use Ecto.Migration

  def change do
    create table(:worker_tasks) do
      add :worker_id, references(:users, on_delete: :delete_all)
      add :task_id, references(:tasks, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:worker_tasks, [:worker_id])
    create index(:worker_tasks, [:task_id])
    create unique_index(:worker_tasks, [:task_id, :worker_id])
  end
end
