defmodule ProjeXpert.Repo.Migrations.AddPaymentMethodInPayments do
  use Ecto.Migration

  def up do
    alter table(:payments) do
      add :payment_method_id, references(:payment_methods, on_delete: :delete_all)
    end
  end

  def down do
    alter table(:payments) do
      add :payment_method_id, references(:payment_methods, on_delete: :delete_all)
    end
  end
end
