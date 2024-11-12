defmodule ProjeXpert.Tasks.Bid do
  use ProjeXpert.Schema
  import Ecto.Changeset

  @statuses [:submitted, :under_review, :accepted, :rejected, :withdrawn]
  @default_cast [:amount, :status, :description, :attached_files, :task_id, :freelancer_id]
  @default_required [:amount, :status, :description, :task_id, :freelancer_id]
  schema "bids" do
    field :status, Ecto.Enum, values: @statuses, default: :submitted
    field :amount, :decimal
    field :description, :string
    field :attached_files, {:array, :string}

    belongs_to :task, ProjeXpert.Tasks.Task, foreign_key: :task_id
    belongs_to :freelancer, ProjeXpert.Accounts.User, foreign_key: :freelancer_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bid, attrs) do
    bid
    |> cast(attrs, @default_cast)
    |> validate_required(@default_required)
  end

  def all_statuses, do: @statuses

  def statuses_as_options,
    do:
      Enum.map(@statuses, fn status ->
        {ProjeXpertWeb.LiveHelpers.camel_case_string(status), status}
      end)

  def valid?(status) when status in @statuses, do: true
  def valid?(_), do: false
end
