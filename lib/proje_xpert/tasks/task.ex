defmodule ProjeXpert.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias ProjeXpert.Accounts.User
  alias ProjeXpert.Tasks.{Bid, Comment, Column, Project, WorkerTask, WorkerProject}
  alias ProjeXpertWeb.LiveHelpers

  @default_cast [
    :title,
    :description,
    :is_completed?,
    :find_worker?,
    :attachments,
    :tags,
    :budget,
    :deadline,
    :project_id,
    :column_id
  ]
  @default_required [:title, :description, :is_completed?, :budget, :deadline, :project_id]
  @experiences [:beginner, :intermediate, :expert]

  schema "tasks" do
    field :description, :string
    field :title, :string
    field :find_worker?, :boolean, default: false
    field :deadline, :date
    field :budget, :decimal
    field :attachments, {:array, :string}, default: []
    field :is_completed?, :boolean
    field :tags, {:array, :string}, default: []
    field :experience_required, Ecto.Enum, values: @experiences

    belongs_to :project, Project, foreign_key: :project_id
    belongs_to :column, Column, foreign_key: :column_id
    has_many :bids, Bid
    has_many :comments, Comment, foreign_key: :task_id
    has_many :worker_tasks, WorkerTask, foreign_key: :task_id

    many_to_many :workers, User,
      join_through: WorkerProject,
      join_keys: [worker_id: :id, task_id: :id]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, @default_cast)
    |> validate_required(@default_required)
  end

  def task_comment_changeset(task, attrs) do
    task
    |> cast(attrs, @default_cast)
    |> validate_required(@default_required)
    |> cast_assoc(:comments, with: &Comment.changeset/2)
  end

  def all_experiences, do: @experiences

  def experiences_as_options,
    do:
      Enum.map(@experiences, fn experience ->
        {LiveHelpers.camel_case_string(experience), experience}
      end)

  def valid?(experience) when experience in @experiences, do: true
  def valid?(_), do: false
end
