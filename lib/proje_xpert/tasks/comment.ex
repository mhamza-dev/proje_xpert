defmodule ProjeXpert.Tasks.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :message, :string

    belongs_to :user, ProjeXpert.Accounts.User, foreign_key: :user_id
    belongs_to :task, ProjeXpert.Tasks.Task, foreign_key: :task_id
    has_many :replies, ProjeXpert.Tasks.Reply, foreign_key: :comment_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:message, :user_id, :task_id])
    |> validate_required([:message, :user_id, :task_id])
  end
end
