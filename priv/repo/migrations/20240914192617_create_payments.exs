defmodule ProjeXpert.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :amount, :decimal
      add :status, :string
      add :payment_method, :string
      add :task_id, references(:tasks, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:payments, [:task_id])
  end
end
