defmodule ProjeXpert.Stripe.PaymentMethod do
  alias ProjeXpert.Stripe.ApiClient

  @moduledoc """
  A module for interacting with the Stripe API to manage payment methods.

  This module provides functions to create, update, retrieve, attach, and detach payment methods in Stripe.
  """

  @type create :: %{
          required(:type) => String.t(),
          optional(:card) => %{
            optional(:token) => String.t(),
            optional(:number) => String.t(),
            optional(:exp_month) => integer(),
            optional(:exp_year) => integer(),
            optional(:cvc) => String.t(),
            optional(:name) => String.t(),
            optional(:address) => %{
              optional(:line1) => String.t(),
              optional(:line2) => String.t(),
              optional(:city) => String.t(),
              optional(:state) => String.t(),
              optional(:postal_code) => String.t(),
              optional(:country) => String.t()
            }
          },
          optional(:billing_details) => %{
            optional(:name) => String.t(),
            optional(:email) => String.t(),
            optional(:phone) => String.t(),
            optional(:address) => %{
              optional(:line1) => String.t(),
              optional(:line2) => String.t(),
              optional(:city) => String.t(),
              optional(:state) => String.t(),
              optional(:postal_code) => String.t(),
              optional(:country) => String.t()
            }
          }
        }

  @type update :: %{
          optional(:metadata) => %{String.t() => String.t()},
          optional(:billing_details) => %{
            optional(:name) => String.t(),
            optional(:email) => String.t(),
            optional(:phone) => String.t(),
            optional(:address) => %{
              optional(:line1) => String.t(),
              optional(:line2) => String.t(),
              optional(:city) => String.t(),
              optional(:state) => String.t(),
              optional(:postal_code) => String.t(),
              optional(:country) => String.t()
            }
          }
        }

  @type payment_method :: %{
          required(:id) => String.t(),
          required(:object) => String.t(),
          required(:type) => String.t(),
          optional(:card) => %{
            required(:brand) => String.t(),
            required(:last4) => String.t(),
            required(:exp_month) => integer(),
            required(:exp_year) => integer(),
            optional(:country) => String.t(),
            optional(:funding) => String.t(),
            optional(:checks) => %{
              optional(:cvc_check) => String.t(),
              optional(:address_line1_check) => String.t(),
              optional(:address_postal_code_check) => String.t()
            }
          },
          optional(:billing_details) => %{
            optional(:name) => String.t(),
            optional(:email) => String.t(),
            optional(:phone) => String.t(),
            optional(:address) => %{
              optional(:line1) => String.t(),
              optional(:line2) => String.t(),
              optional(:city) => String.t(),
              optional(:state) => String.t(),
              optional(:postal_code) => String.t(),
              optional(:country) => String.t()
            }
          },
          optional(:created) => integer(),
          optional(:customer) => String.t(),
          optional(:metadata) => %{String.t() => String.t()}
        }

  @type attach :: %{
          required(:customer) => String.t()
        }

  @type detach :: %{
          required(:customer) => String.t()
        }

  @type api_response :: {:ok, payment_method()} | {:error, any()}

  @doc """
  Creates a new payment method in Stripe.

  ## Parameters

    - `params`: A map containing the payment method details. The following fields are required or optional:
      - `:type` - The type of the payment method (e.g., "card").
      - `:card` - A map containing card details (number, exp_month, exp_year, cvc, name, address).
      - `:billing_details` - A map containing billing details (name, email, phone, address).

  ## Examples

      iex> ProjeXpert.Stripe.PaymentMethod.create(%{
      ...>   type: "card",
      ...>   card: %{number: "4242XXXXXXXXXXXX", exp_month: 12, exp_year: 2025, cvc: "123"},
      ...>   billing_details: %{name: "John Doe ...>   }
      ...> })
      {:ok, %{id: "pm_123", object: "payment_method"}}

  ## Returns

    - `{:ok, payment_method}` on success.
    - `{:error, reason}` on failure.
  """
  @spec create(create()) :: api_response()
  def create(params) do
    ApiClient.post_api("/payment_methods", params)
  end

  @doc """
  Updates an existing payment method in Stripe.

  ## Parameters

    - `id`: The ID of the payment method to update.
    - `params`: A map containing the fields to update. The following fields are optional:
      - `:metadata` - A map of key-value pairs to store additional information.
      - `:billing_details` - A map containing billing details (name, email, phone, address).

  ## Examples

      iex> ProjeXpert.Stripe.PaymentMethod.update("pm_123", %{metadata: %{key: "value"}})
      {:ok, %{id: "pm_123", object: "payment_method", metadata: %{key: "value"}}}

  ## Returns

    - `{:ok, payment_method}` on success.
    - `{:error, reason}` on failure.
  """
  @spec update(String.t(), update()) :: api_response()
  def update(id, params) do
    ApiClient.post_api("/payment_methods/#{id}", params)
  end

  @doc """
  Retrieves a payment method by ID from Stripe.

  ## Parameters

    - `id`: The ID of the payment method to retrieve.

  ## Examples

      iex> ProjeXpert.Stripe.PaymentMethod.get("pm_123")
      {:ok, %{id: "pm_123", object: "payment_method"}}

  ## Returns

    - `{:ok, payment_method}` on success.
    - `{:error, reason}` on failure.
  """
  @spec get(String.t()) :: api_response()
  def get(id) do
    ApiClient.get_api("/payment_methods/#{id}")
  end

  @doc """
  Attaches a payment method to a customer in Stripe.

  ## Parameters

    - `id`: The ID of the payment method to attach.
    - `params`: A map containing the customer ID.

  ## Examples

      iex> ProjeXpert.Stripe.PaymentMethod.attach("pm_123", %{customer: "cus_123"})
      {:ok, %{id: "pm_123", object: "payment_method", customer: "cus_123"}}

  ## Returns

    - `{:ok, payment_method}` on success.
    - `{:error, reason}` on failure.
  """
  @spec attach(String.t(), attach()) :: api_response()
  def attach(id, params) do
    ApiClient.post_api("/payment_methods/#{id}/attach", params)
  end

  @doc """
  Detaches a payment method from a customer in Stripe.

  ## Parameters

    - `id`: The ID of the payment method to detach.
    - `params`: A map containing the customer ID.

  ## Examples

      iex> ProjeXpert.Stripe.PaymentMethod.detach("pm_123", %{customer: "cus_123"})
      {:ok, %{id: "pm_123", object: "payment_method", detached: true}}

  ## Returns

    - `{:ok, response}` on success.
    - `{:error, reason}` on failure.
  """
  @spec detach(String.t(), detach()) :: api_response()
  def detach(id, params) do
    ApiClient.post_api("/payment_methods/#{id}/detach", params)
  end
end
