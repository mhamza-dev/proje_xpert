defmodule ProjeXpert.Chats.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "channels" do
    field :name, :string
    belongs_to :created_by, ProjeXpert.Accounts.User, foreign_key: :created_by_id
    has_many :channel_users, ProjeXpert.Chats.ChannelUser

    many_to_many :users, ProjeXpert.Accounts.User,
      join_through: ProjeXpert.Chats.ChannelUser,
      join_keys: [user_id: :id, channel_id: :id]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
