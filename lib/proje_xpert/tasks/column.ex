defmodule ProjeXpert.Tasks.Column do
  use Ecto.Schema
  import Ecto.Changeset

  @default_cast [:name, :project_id]
  @default_validte [:name, :project_id]
  schema "columns" do
    field :name, :string

    belongs_to :project, ProjeXpert.Tasks.Project, foreign_key: :project_id
    has_many :tasks, ProjeXpert.Tasks.Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(column, attrs) do
    column
    |> cast(attrs, @default_cast)
    |> validate_required(@default_validte)
  end
end
