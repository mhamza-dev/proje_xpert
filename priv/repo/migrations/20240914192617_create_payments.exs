defmodule ProjeXpert.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :amount, :decimal
      add :status, :string
      add :payment_method, :string
      add :bid_id, references(:bids, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:payments, [:bid_id])
  end
end
