defmodule ProjeXpert.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :message, :text
      add :user_id, references(:users, on_delete: :delete_all)
      add :task_id, references(:tasks, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:user_id])
    create index(:comments, [:task_id])
  end
end
