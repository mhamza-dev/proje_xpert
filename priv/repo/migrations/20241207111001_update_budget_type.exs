defmodule ProjeXpert.Repo.Migrations.UpdateBudgetType do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      modify :budget, :float
    end

    alter table(:tasks) do
      modify :budget, :float
    end

    alter table(:payments) do
      modify :amount, :float
    end
  end
end
