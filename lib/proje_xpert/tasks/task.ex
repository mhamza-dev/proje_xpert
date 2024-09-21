defmodule ProjeXpert.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @default_cast [:title, :description, :budget, :deadline, :project_id, :column_id]
  @default_required [:title, :description, :budget, :deadline, :project_id]
  schema "tasks" do
    field :description, :string
    field :title, :string
    field :deadline, :date
    field :budget, :decimal

    belongs_to :project, ProjeXpert.Tasks.Project, foreign_key: :project_id
    belongs_to :column, ProjeXpert.Tasks.Column, foreign_key: :column_id
    has_many :bids, ProjeXpert.Tasks.Bid
    has_many :worker_tasks, ProjeXpert.Tasks.WorkerTask, foreign_key: :task_id

    many_to_many :workers, ProjeXpert.Accounts.User,
      join_through: ProjeXpert.Tasks.WorkerProject,
      join_keys: [worker_id: :id, task_id: :id]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, @default_cast)
    |> validate_required(@default_required)
  end
end
