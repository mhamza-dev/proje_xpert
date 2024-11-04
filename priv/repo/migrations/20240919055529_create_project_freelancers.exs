defmodule ProjeXpert.Repo.Migrations.CreatefreelancerProjects do
  use Ecto.Migration

  def change do
    create table(:project_freelancers) do
      add :freelancer_id, references(:users, on_delete: :delete_all)
      add :project_id, references(:projects, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:project_freelancers, [:freelancer_id])
    create index(:project_freelancers, [:project_id])
    create unique_index(:project_freelancers, [:project_id, :freelancer_id])
  end
end
