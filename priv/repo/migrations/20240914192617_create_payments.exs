defmodule ProjeXpert.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :amount, :decimal
      add :status, :string
      add :payment_method, :string
      add :description, :string
      add :task_id, references(:tasks, on_delete: :delete_all)
      add :receiver_id, references(:users, on_delete: :delete_all)
      add :payer_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:payments, [:task_id, :receiver_id, :payer_id])
  end
end
