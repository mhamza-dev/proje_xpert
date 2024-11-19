defmodule ProjeXpert.Tasks.Sprint do
  use ProjeXpert.Schema
  import Ecto.Changeset

  @default_sprints ["Sprint 1", "Sprint 2", "Sprint 3", "Sprint 4", "Sprint 5"]

  schema "sprints" do
    field :title, :string
    field :start_date, :date
    field :end_date, :date
    field :status, Ecto.Enum, values: [:pending, :in_progress, :completed], default: :pending

    has_many :columns, ProjeXpert.Tasks.Column, foreign_key: :sprint_id
    has_many :tasks, ProjeXpert.Tasks.Task, foreign_key: :sprint_id
    belongs_to :project, ProjeXpert.Tasks.Project, foreign_key: :project_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sprint, attrs) do
    sprint
    |> cast(attrs, [:title, :start_date, :end_date, :status, :project_id])
    |> validate_required([:title, :start_date, :end_date, :status, :project_id])
  end

  def get_default_sprints, do: @default_sprints
end
