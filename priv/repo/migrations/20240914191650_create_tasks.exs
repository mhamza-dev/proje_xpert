defmodule ProjeXpert.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string
      add :description, :text
      add :find_worker?, :boolean
      add :budget, :decimal
      add :deadline, :date
      add :attachments, {:array, :string}, default: []
      add :is_completed?, :boolean, default: false
      add :tags, {:array, :string}, default: []
      add :experience_required, :string
      add :project_id, references(:projects, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:project_id])
  end
end
