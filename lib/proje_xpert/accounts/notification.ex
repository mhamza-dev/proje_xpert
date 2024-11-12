defmodule ProjeXpert.Accounts.Notification do
  use ProjeXpert.Schema
  import Ecto.Changeset

  alias ProjeXpert.Accounts.User

  schema "notifications" do
    field :message, :string
    field :type, Ecto.Enum, values: [:email, :sms, :push]
    field :is_read?, :boolean, default: false
    field :link, :string

    belongs_to :user, User, foreign_key: :user_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:type, :message, :is_read?, :link, :user_id])
    |> validate_required([:type, :message, :is_read?, :link, :user_id])
  end
end
