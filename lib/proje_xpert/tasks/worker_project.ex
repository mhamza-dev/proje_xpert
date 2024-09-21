defmodule ProjeXpert.Tasks.WorkerProject do
  use Ecto.Schema
  import Ecto.Changeset

  schema "worker_projects" do
    belongs_to :project, ProjeXpert.Tasks.Project, foreign_key: :project_id
    belongs_to :user, ProjeXpert.Accounts.User, foreign_key: :worker_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(worker_project, attrs) do
    worker_project
    |> cast(attrs, [])
    |> validate_required([])
  end
end
