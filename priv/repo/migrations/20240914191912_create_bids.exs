defmodule ProjeXpert.Repo.Migrations.CreateBids do
  use Ecto.Migration

  def change do
    create table(:bids) do
      add :amount, :decimal
      add :status, :string
      add :description, :text
      add :attached_files, {:array, :map}
      add :task_id, references(:tasks, on_delete: :nothing)
      add :worker_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:bids, [:task_id])
    create index(:bids, [:worker_id])
  end
end
