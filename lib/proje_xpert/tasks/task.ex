defmodule ProjeXpert.Tasks.Task do
  use ProjeXpert.Schema
  import Ecto.Changeset

  alias ProjeXpert.Accounts.User
  alias ProjeXpert.Tasks.{Bid, Comment, Column, Project, Sprint}
  alias ProjeXpertWeb.LiveHelpers

  @default_cast [
    :title,
    :description,
    :is_completed?,
    :find_freelancer?,
    :attachments,
    :tags,
    :budget,
    :deadline,
    :ask_for_payment,
    :project_id,
    :sprint_id,
    :freelancer_id,
    :column_id
  ]
  @default_required [
    :title,
    :description,
    :is_completed?,
    :budget,
    :deadline,
    :project_id,
    :sprint_id
  ]
  @experiences [:beginner, :intermediate, :expert]

  schema "tasks" do
    field :description, :string
    field :title, :string
    field :find_freelancer?, :boolean, default: false
    field :deadline, :date
    field :budget, :decimal
    field :attachments, {:array, :string}, default: []
    field :is_completed?, :boolean
    field :tags, {:array, :string}, default: []
    field :experience_required, Ecto.Enum, values: @experiences
    field :ask_for_payment, :boolean, default: false

    belongs_to :project, Project, foreign_key: :project_id
    belongs_to :sprint, Sprint, foreign_key: :sprint_id
    belongs_to :column, Column, foreign_key: :column_id
    belongs_to :freelancer, User, foreign_key: :freelancer_id
    has_many :bids, Bid
    has_many :comments, Comment, foreign_key: :task_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, @default_cast)
    |> validate_required(@default_required)
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
