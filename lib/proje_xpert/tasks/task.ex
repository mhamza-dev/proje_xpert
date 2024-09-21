defmodule ProjeXpert.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses [:not_started, :in_progress, :completed, :on_hold, :cancelled]
  @default_cast [:title, :description, :status, :budget, :deadline, :project_id, :column_id]
  @default_required [:title, :description, :status, :budget, :deadline, :project_id]
  schema "tasks" do
    field :status, Ecto.Enum, values: @statuses
    field :description, :string
    field :title, :string
    field :deadline, :date
    field :budget, :decimal

    belongs_to :project, ProjeXpert.Tasks.Project, foreign_key: :project_id
    belongs_to :column, ProjeXpert.Tasks.Column, foreign_key: :column_id
    has_many :bids, ProjeXpert.Tasks.Bid

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, @default_cast)
    |> validate_required(@default_required)
  end

  def all_statuses, do: @statuses

  def statuses_as_options,
    do:
      Enum.map(@statuses, fn status ->
        {ProjeXpertWeb.LiveHelpers.camel_case_string(status), status}
      end)

  def valid?(status) when status in @statuses, do: true
  def valid?(_), do: false
end
