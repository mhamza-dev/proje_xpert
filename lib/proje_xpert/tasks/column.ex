defmodule ProjeXpert.Tasks.Column do
  use ProjeXpert.Schema
  import Ecto.Changeset

  @default_cast [:name, :sprint_id]
  @default_validate [:name, :sprint_id]
  @default_columns ["Backlog", "In Progress", "Completed"]
  schema "columns" do
    field :name, :string

    belongs_to :sprint, ProjeXpert.Tasks.Sprint, foreign_key: :sprint_id
    has_many :tasks, ProjeXpert.Tasks.Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(column, attrs) do
    column
    |> cast(attrs, @default_cast)
    |> validate_required(@default_validate)
  end

  def get_default_columns, do: @default_columns
end
