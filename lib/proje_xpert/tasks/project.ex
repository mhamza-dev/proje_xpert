defmodule ProjeXpert.Tasks.Project do
  use ProjeXpert.Schema
  import Ecto.Changeset

  @statuses [:pending, :in_progress, :completed, :on_hold]
  @default_cast [:title, :description, :status, :budget, :client_id]
  @default_required [:title, :description, :status, :budget, :client_id]

  schema "projects" do
    field :status, Ecto.Enum, values: @statuses, default: :pending
    field :description, :string
    field :title, :string
    field :budget, :float

    # Associations
    belongs_to :client, ProjeXpert.Accounts.User, foreign_key: :client_id
    has_many :tasks, ProjeXpert.Tasks.Task
    has_many :sprints, ProjeXpert.Tasks.Sprint
    has_one :channel, ProjeXpert.Chats.Channel
    has_many :project_freelancers, ProjeXpert.Tasks.Projectfreelancer, foreign_key: :project_id

    many_to_many :freelancers, ProjeXpert.Accounts.User,
      join_through: ProjeXpert.Tasks.Projectfreelancer,
      join_keys: [freelancer_id: :id, project_id: :id]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, @default_cast)
    |> validate_required(@default_required)
  end

  @doc false
  def create_changeset(project, attrs) do
    project
    |> cast(attrs, @default_cast)
    |> validate_required(@default_required)
    |> cast_assoc(:sprints, required: true, with: &ProjeXpert.Tasks.Sprint.changeset/2)
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
