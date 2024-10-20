defmodule ProjeXpert.Chats.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :body, :string
    belongs_to :sender, ProjeXpert.Accounts.User, foreign_key: :sender_id
    belongs_to :channel, ProjeXpert.Chats.Channel, foreign_key: :channel_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
