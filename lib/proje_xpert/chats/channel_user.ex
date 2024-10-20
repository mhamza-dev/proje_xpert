defmodule ProjeXpert.Chats.ChannelUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "channel_users" do
    belongs_to :channel, ProjeXpert.Chats.Channel, foreign_key: :channel_id
    belongs_to :user, ProjeXpert.Accounts.User, foreign_key: :user_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(channel_user, attrs) do
    channel_user
    |> cast(attrs, [])
    |> validate_required([])
  end
end
