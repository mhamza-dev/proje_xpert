defmodule ProjeXpert.Tasks.Payment do
  use ProjeXpert.Schema
  import Ecto.Changeset

  @statuses [:pending, :completed, :failed, :refunded, :cancelled]
  @default_cast [
    :amount,
    :status,
    :description,
    :task_id,
    :receiver_id,
    :payer_id,
    :payment_method_id
  ]
  @default_required [
    :amount,
    :status,
    :description,
    :task_id,
    :receiver_id,
    :payer_id,
    :payment_method_id
  ]
  schema "payments" do
    field :status, Ecto.Enum, values: @statuses, default: :pending
    field :amount, :float
    field :description, :string

    belongs_to :task, ProjeXpert.Tasks.Task, foreign_key: :task_id
    belongs_to :receiver, ProjeXpert.Accounts.User, foreign_key: :receiver_id
    belongs_to :payer, ProjeXpert.Accounts.User, foreign_key: :payer_id
    belongs_to :payment_method, ProjeXpert.Accounts.PaymentMethod, foreign_key: :payment_method_id

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
