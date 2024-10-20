defmodule ProjeXpert.Repo.Migrations.CreateChannelUsers do
  use Ecto.Migration

  def change do
    create table(:channel_users) do
      add :channel_id, references(:channels, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:channel_users, [:channel_id])
    create index(:channel_users, [:user_id])
  end
end
