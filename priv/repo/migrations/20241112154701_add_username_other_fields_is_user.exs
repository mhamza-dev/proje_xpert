defmodule ProjeXpert.Repo.Migrations.AddUsernameOtherFieldsIsUser do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :username, :string
      add :birthdate, :date
      add :gender, :string
      add :terms, :boolean, default: false
    end
  end

  def down do
    alter table(:users) do
      remove :username, :string
      remove :birthdate, :date
      remove :gender, :string
      remove :terms, :boolean, default: false
    end
  end
end
