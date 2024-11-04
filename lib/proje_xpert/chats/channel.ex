defmodule ProjeXpert.Chats.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  @default_cast [:name, :joiners, :created_by_id, :project_id]
  @default_required [:name, :joiners, :created_by_id]
  schema "channels" do
    field :name, :string
    field :joiners, {:array, :integer}
    belongs_to :created_by, ProjeXpert.Accounts.User, foreign_key: :created_by_id
    belongs_to :project, ProjeXpert.Tasks.Project, foreign_key: :project_id
    has_many :messages, ProjeXpert.Chats.Message, foreign_key: :channel_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, @default_cast)
    |> validate_required(@default_required)
  end
end
