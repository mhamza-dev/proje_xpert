defmodule ProjeXpert.Tasks.Reply do
  use Ecto.Schema
  import Ecto.Changeset

  schema "replies" do
    field :message, :string

    belongs_to :user, ProjeXpert.Accounts.User, foreign_key: :user_id
    belongs_to :comment, ProjeXpert.Tasks.Comment, foreign_key: :comment_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reply, attrs) do
    reply
    |> cast(attrs, [:message, :user_id, :comment_id])
    |> validate_required([:message, :user_id, :comment_id])
  end
end
