defmodule ProjeXpert.Stripe.PaymentIntent do
  alias ProjeXpert.Stripe.ApiClient

  @type create :: %{
          required(:amount) => integer(),
          required(:currency) => String.t(),
          optional(:payment_method) => String.t(),
          optional(:description) => String.t(),
          optional(:metadata) => %{String.t() => String.t()},
          optional(:automatic_payment_methods) => %{
            required(:enabled) => boolean(),
            required(:allow_redirects) => String.t()
          },
          optional(:confirm) => boolean(),
          optional(:customer) => String.t(),
          optional(:receipt_email) => String.t(),
          optional(:capture) => boolean()
        }

  @type payment_intent :: %{
          required(:id) => String.t(),
          required(:object) => String.t(),
          required(:amount) => integer(),
          required(:currency) => String.t(),
          required(:status) => String.t(),
          required(:created) => integer(),
          optional(:description) => String.t(),
          optional(:metadata) => %{String.t() => String.t()},
          optional(:payment_method) => String.t(),
          optional(:customer) => String.t(),
          optional(:client_secret) => String.t(),
          optional(:charges) => %{
            required(:object) => String.t(),
            required(:data) => [map()],
            optional(:has_more) => boolean(),
            optional(:total_count) => integer(),
            optional(:url) => String.t()
          }
        }

  @type all_api_response :: {:ok, [payment_intent()]} | {:error, any()}
  @type api_response :: {:ok, payment_intent()} | {:error, any()}

  @doc """
  Creates a new payment intent.

  ## Parameters

    - `params`: A map containing the required and optional parameters for creating a payment intent.

  ## Examples

      iex> ProjeXpert.Stripe.PaymentIntent.create(%{amount: 1000, currency: "usd"})
      {:ok, %{
        id: "pi_1GqIC2L2eZvKYlo2C1g1g1g1",
        amount: 1000,
        currency: "usd",
        status: "requires_payment_method",
        created: 1630000000,
        client_secret: "secret_123456789"
      }}

  """
  @spec create(create()) :: api_response()
  def create(params) do
    ApiClient.post_api("/payment_intents", params)
  end

  @doc """
  Retrieves a payment intent by its ID.

  ## Parameters

    - `id`: The ID of the payment intent to retrieve.

  ## Examples

      iex> ProjeXpert.Stripe.PaymentIntent.get("pi_1GqIC2L2eZvKYlo2C1g1g1g1")
      {:ok, %{
        id: "pi_1GqIC2L2eZvKYlo2C1g1g1g1",
        amount: 1000,
        currency: "usd",
        status: "succeeded",
        created: 1630000000,
        client_secret: "secret_123456789"
      }}

  """
  @spec get(String.t()) :: api_response()
  def get(id) do
    ApiClient.get_api("/payment_intents/#{id}")
  end

  @doc """
  Retrieves all payment intents.

  ## Examples

      iex> ProjeXpert.Stripe.PaymentIntent.get_all()
      {:ok, [%{...}, %{...}]}

  """
  @spec get_all() :: all_api_response()
  def get_all do
    ApiClient.get_api("/payment_intents")
  end

  @doc """
  Confirm a payment intent.

  ## Parameters

    - `id`: The ID of the payment intent to confirm.
    - `params`: Optional parameters for confirmation.

  ## Examples

      iex> ProjeXpert.Stripe.PaymentIntent.confirm("pi_1GqIC2L2eZvKYlo2C1g1g1g1", %{payment_method: "pm_card_visa"})
      {:ok, %{
        id: "pi_1GqIC2L2eZvKYlo2C1g1g1g1",
        status: "succeeded",
        ...
      }}

  """
  @spec confirm(String.t(), map()) :: api_response()
  def confirm(id, params \\ %{}) do
    ApiClient.post_api("/payment_intents/#{id}/confirm", params)
  end

  @doc """
  Cancel a payment intent.

  ## Parameters

    - `id`: The ID of the payment intent to cancel.

  ## Examples

      iex> ProjeXpert .Stripe.PaymentIntent.cancel("pi_1GqIC2L2eZvKYlo2C1g1g1g1")
      {:ok, %{
        id: "pi_1GqIC2L2eZvKYlo2C1g1g1g1",
        status: "canceled",
        ...
      }}

  """
  @spec cancel(String.t()) :: api_response()
  def cancel(id) do
    ApiClient.post_api("/payment_intents/#{id}/cancel", %{})
  end
end
