defmodule ProjeXpert.Tasks.WorkerTask do
  use Ecto.Schema
  import Ecto.Changeset

  schema "worker_tasks" do
    belongs_to :task, ProjeXpert.Tasks.Task, foreign_key: :task_id
    belongs_to :user, ProjeXpert.Accounts.User, foreign_key: :worker_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(worker_task, attrs) do
    worker_task
    |> cast(attrs, [])
    |> validate_required([])
  end
end
