defmodule ProjeXpert.Tasks.Projectfreelancer do
  use ProjeXpert.Schema
  import Ecto.Changeset

  schema "project_freelancers" do
    belongs_to :project, ProjeXpert.Tasks.Project, foreign_key: :project_id
    belongs_to :freelancer, ProjeXpert.Accounts.User, foreign_key: :freelancer_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(freelancer_project, attrs) do
    freelancer_project
    |> cast(attrs, [:project_id, :freelancer_id])
    |> validate_required([:project_id, :freelancer_id])
  end
end
