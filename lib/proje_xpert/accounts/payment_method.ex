defmodule ProjeXpert.Accounts.PaymentMethod do
  use ProjeXpert.Schema
  import Ecto.Changeset

  alias ProjeXpertWeb.LiveHelpers
  alias ProjeXpert.Accounts.User

  @default_cast [
    :brand,
    :card_id,
    :default,
    :last_four_digits,
    :card_holder_name,
    :expiry,
    :user_id
  ]

  schema "payment_methods" do
    field :brand, :string
    field :card_id, :string
    field :default, :boolean, default: false
    field :last_four_digits, :string
    field :card_holder_name, :string
    field :expiry, :string

    belongs_to :user, User, foreign_key: :user_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def validate_changeset(payment_method, attrs) do
    payment_method
    |> cast(attrs, @default_cast)
    |> validate_required(@default_cast)
    |> validate_card_holder_name()
    |> validate_expiry()
    |> validate_cvv()
    |> validate_card_number()
  end

  @doc false
  def create_changeset(payment_method, attrs) do
    payment_method
    |> cast(attrs, @default_cast)
    |> validate_required(@default_cast)
    |> validate_card_holder_name()
    |> validate_expiry()
    |> validate_cvv()
  end

  defp validate_card_holder_name(changeset) do
    validate_length(changeset, :card_holder_name, min: 1)
  end

  defp validate_expiry(changeset) do
    case get_change(changeset, :expiry) do
      nil ->
        changeset

      expiry ->
        current_date = Date.utc_today()

        case String.split(expiry, "/") do
          # Case where both month and year are provided
          [exp_month, exp_year] ->
            with {month, ""} <- Integer.parse(exp_month),
                 {year, ""} <- Integer.parse("20#{exp_year}"),
                 {:ok, _} <- check_month(month),
                 exp_date <- Date.new!(year, month, 1),
                 {:ok, _} <- check_date(exp_date, current_date) do
              changeset
            else
              # Handle cases where parsing fails
              :error ->
                add_error(changeset, :expiry, "expiry month and year must be numbers")

              # Handle cases where the month is out of range
              {:error, "month"} ->
                add_error(changeset, :expiry, "expiry month must be between 01 and 12")

              # Handle cases where the date is out of range
              {:error, "date"} ->
                add_error(changeset, :expiry, "expiry must be a valid future date")

              # Handle cases where the date is not in the future
              _ ->
                add_error(
                  changeset,
                  :expiry,
                  "expiry must be a valid future date in MM/YY format"
                )
            end

          # Case where only month is provided, missing year
          [exp_month] ->
            if exp_month |> String.match?(~r/^\d{1,2}$/) do
              add_error(
                changeset,
                :expiry,
                "expiry must include both month and year in MM/YY format"
              )
            else
              add_error(changeset, :expiry, "expiry month must be a number")
            end

          # Handle any other format issues
          _ ->
            add_error(changeset, :expiry, "expiry must be in MM/YY format")
        end
    end
  end

  defp validate_cvv(changeset) do
    case get_change(changeset, :cvv) do
      nil ->
        changeset

      cvv ->
        if is_integer(cvv) and (cvv >= 100 and cvv <= 9999) do
          changeset
        else
          add_error(changeset, :cvv, "must be a valid CVV (3 or 4 digits)")
        end
    end
  end

  defp validate_card_number(changeset) do
    case get_change(changeset, :last_four_digits) do
      nil ->
        changeset

      last_four_digits ->
        cond do
          String.length(last_four_digits) == 16 ->
            changeset

          !LiveHelpers.is_integer?(last_four_digits) ->
            add_error(changeset, :last_four_digits, "must be number")

          true ->
            add_error(changeset, :last_four_digits, "should have 16 digits")
        end
    end
  end

  defp check_month(month) do
    if month in 1..12 do
      {:ok, "month"}
    else
      {:error, "month"}
    end
  end

  defp check_date(exp_date, current_date) do

    if Date.compare(exp_date, current_date) == :gt do
      {:ok, "date"}
    else
      {:error, "date"}
    end
  end
end
