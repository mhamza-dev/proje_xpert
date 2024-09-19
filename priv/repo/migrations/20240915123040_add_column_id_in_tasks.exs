defmodule ProjeXpert.Repo.Migrations.AddColumnIdInTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :column_id, references(:columns, on_delete: :restrict)
    end
  end
end
