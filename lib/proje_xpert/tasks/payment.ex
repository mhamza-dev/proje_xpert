defmodule ProjeXpert.Tasks.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses [:pending, :completed, :failed, :refunded, :cancelled]
  @default_cast [:amount, :status, :payment_method]
  @default_required [:amount, :status, :payment_method]
  schema "payments" do
    field :status, Ecto.Enum, values: @statuses
    field :amount, :decimal
    field :payment_method, :string

    belongs_to :bid, ProjeXpert.Tasks.Bid, foreign_key: :bid_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, @default_cast)
    |> validate_required(@default_required)
  end

  def all_statuses, do: @statuses

  def valid?(status) when status in @statuses, do: true
  def valid?(_), do: false
end
