defmodule ProjeXpert.Tasks.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :message, :string

    belongs_to :sender, ProjeXpert.Accounts.User, foreign_key: :sender_id
    belongs_to :receiver, ProjeXpert.Accounts.User, foreign_key: :receiver_id
    belongs_to :task, ProjeXpert.Tasks.Task, foreign_key: :task_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:message, :sender_id, :receiver_id, :task_id])
    |> validate_required([:message, :sender_id, :receiver_id, :task_id])
  end
end
