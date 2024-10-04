defmodule ProjeXpert.Repo.Migrations.AddProviderInUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :provider, :string, default: "creds"
      modify :hashed_password, :string, null: true
    end
  end

  def down do
    alter table(:users) do
      remove :provider
      modify :hashed_password, :string, null: false
    end
  end
end
