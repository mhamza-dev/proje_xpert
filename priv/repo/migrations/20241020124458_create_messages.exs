defmodule ProjeXpert.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :body, :text
      add :read_by, {:array, :integer}, default: []
      add :sender_id, references(:users, on_delete: :nothing)
      add :channel_id, references(:channels, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:sender_id])
    create index(:messages, [:channel_id])
  end
end
