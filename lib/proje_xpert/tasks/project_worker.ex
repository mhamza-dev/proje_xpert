defmodule ProjeXpert.Tasks.ProjectWorker do
  use Ecto.Schema
  import Ecto.Changeset

  schema "project_workers" do
    belongs_to :project, ProjeXpert.Tasks.Project, foreign_key: :project_id
    belongs_to :worker, ProjeXpert.Accounts.User, foreign_key: :worker_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(worker_project, attrs) do
    worker_project
    |> cast(attrs, [:project_id, :worker_id])
    |> validate_required([:project_id, :worker_id])
  end
end
