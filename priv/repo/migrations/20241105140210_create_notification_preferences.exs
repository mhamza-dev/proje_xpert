defmodule ProjeXpert.Repo.Migrations.CreateNotificationPreferences do
  use Ecto.Migration

  def change do
    create table(:notification_preferences) do
      add :email, :boolean, default: false, null: false
      add :sms, :boolean, default: false, null: false
      add :push, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
