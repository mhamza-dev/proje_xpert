defmodule ProjeXpert.Tasks.Project do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses [:pending, :in_progress, :completed, :on_hold, :cancelled]
  @default_cast [:title, :description, :status, :budget, :client_id]
  @default_required [:title, :description, :status, :budget, :client_id]

  schema "projects" do
    field :status, Ecto.Enum, values: @statuses, default: :pending
    field :description, :string
    field :title, :string
    field :budget, :decimal

    belongs_to :user, ProjeXpert.Accounts.User, foreign_key: :client_id
    has_many :tasks, ProjeXpert.Tasks.Task
    has_many :workers, ProjeXpert.Tasks.User
    has_many :columns, ProjeXpert.Tasks.Column

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, @default_cast)
    |> validate_required(@default_required)
  end

  def all_statuses, do: @statuses
  def statuses_as_options, do: Enum.map(@statuses, fn status -> {ProjeXpertWeb.LiveHelpers.camel_case_string(status), status}end)

  def valid?(status) when status in @statuses, do: true
  def valid?(_), do: false
end
