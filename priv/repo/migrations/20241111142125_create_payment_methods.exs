defmodule ProjeXpert.Repo.Migrations.CreatePaymentMethods do
  use Ecto.Migration

  def change do
    create table(:payment_methods) do
      add :brand, :string
      add :card_id, :string
      add :default, :boolean, default: false
      add :last_four_digits, :string
      add :card_holder_name, :string
      add :expiry, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:payment_methods, [:user_id])
  end
end
