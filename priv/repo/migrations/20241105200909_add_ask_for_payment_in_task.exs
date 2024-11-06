defmodule ProjeXpert.Repo.Migrations.AddAskForPaymentInTask do
  use Ecto.Migration

  def up do
    alter table(:tasks) do
      add :ask_for_payment, :boolean, default: false
    end
  end

  def down do
    alter table(:tasks) do
      remove :ask_for_payment
    end
  end
end
