defmodule ProjeXpert.Accounts.NotificationPreference do
  use ProjeXpert.Schema
  import Ecto.Changeset
  alias ProjeXpert.Accounts.User

  schema "notification_preferences" do
    field :email, :boolean, default: false
    field :sms, :boolean, default: false
    field :push, :boolean, default: false

    belongs_to :user, User, foreign_key: :user_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification_preference, attrs) do
    notification_preference
    |> cast(attrs, [:email, :sms, :push, :user_id])
    |> validate_required([:email, :sms, :push, :user_id])
  end
end
