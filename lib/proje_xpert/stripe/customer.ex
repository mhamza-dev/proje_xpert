defmodule ProjeXpert.Stripe.Customer do
  alias ProjeXpert.Stripe.ApiClient

  @moduledoc """
  A module for interacting with the Stripe API to manage customers.

  This module provides functions to create, update, retrieve, and delete customers in Stripe.
  """

  @type create :: %{
          optional(:email) => String.t(),
          optional(:name) => String.t(),
          optional(:description) => String.t(),
          optional(:payment_method) => String.t(),
          optional(:metadata) => %{String.t() => String.t()},
          optional(:address) => %{
            optional(:line1) => String.t(),
            optional(:line2) => String.t(),
            optional(:city) => String.t(),
            optional(:state) => String.t(),
            optional(:postal_code) => String.t(),
            optional(:country) => String.t()
          },
          optional(:phone) => String.t()
        }

  @type update :: %{
          optional(:email) => String.t(),
          optional(:name) => String.t(),
          optional(:description) => String.t(),
          optional(:metadata) => %{String.t() => String.t()},
          optional(:address) => %{
            optional(:line1) => String.t(),
            optional(:line2) => String.t(),
            optional(:city) => String.t(),
            optional(:state) => String.t(),
            optional(:postal_code) => String.t(),
            optional(:country) => String.t()
          },
          optional(:phone) => String.t()
        }

  @type customer :: %{
          required(:id) => String.t(),
          required(:object) => String.t(),
          optional(:email) => String.t(),
          optional(:name) => String.t(),
          optional(:description) => String.t(),
          optional(:metadata) => %{String.t() => String.t()},
          optional(:address) => %{
            optional(:line1) => String.t(),
            optional(:line2) => String.t(),
            optional(:city) => String.t(),
            optional(:state) => String.t(),
            optional(:postal_code) => String.t(),
            optional(:country) => String.t()
          },
          optional(:phone) => String.t(),
          optional(:created) => integer(),
          optional(:default_source) => String.t(),
          optional(:sources) => %{
            required(:object) => String.t(),
            required(:data) => [map()],
            optional(:has_more) => boolean(),
            optional(:total_count) => integer(),
            optional(:url) => String.t()
          }
        }

  @type api_response :: {:ok, customer()} | {:error, any()}
  @type all_api_response :: {:ok, [customer()]} | {:error, any()}

  @doc """
  Creates a new customer in Stripe.

  ## Parameters

    - `params`: A map containing customer details. The following fields are optional:
      - `:email` - The customer's email address.
      - `:name` - The customer's name.
      - `:description` - A description of the customer.
      - `:payment_method` - The ID of a payment method to attach to the customer.
      - `:metadata` - A map of key-value pairs to store additional information.
      - `:address` - A map containing address details (line1, line2, city, state, postal_code, country).
      - `:phone` - The customer's phone number.

  ## Examples

      iex> ProjeXpert.Stripe.Customer.create(%{email: "customer@example.com", name: "John Doe"})
      {:ok, %{id: "cus_123", object: "customer"}}

  ## Returns

    - `{:ok, customer}` on success.
    - `{:error, reason}` on failure.
  """
  @spec create(create()) :: api_response()
  def create(params) do
    ApiClient.post_api("/customers", params)
  end

  @doc """
  Updates an existing customer in Stripe.

  ## Parameters

    - `id`: The ID of the customer to update.
    - `params`: A map containing the fields to update. The following fields are optional:
      - `:email` - The customer's email address.
      - `:name` - The customer's name.
      - `:description` - A description of the customer.
      - `:metadata` - A map of key-value pairs to store additional information.
      - `:address` - A map containing address details (line1, line2, city, state, postal_code, country).
      - `:phone` - The customer's phone number.

  ## Examples

      iex> ProjeXpert.Stripe.Customer.update("cus_123", %{name: "Jane Doe"})
      {:ok, %{id: "cus_123", object: "customer", name: "Jane Doe"}}

  ## Returns

    - `{:ok, customer}` on success.
    - `{:error, reason}` on failure.
  """
  @spec update(String.t(), update()) :: api_response()
  def update(id, params) do
    ApiClient.post_api("/customers/#{id}", params)
  end

  @doc """
  Retrieves a customer by ID from Stripe.

  ## Parameters

    - `id`: The ID of the customer to retrieve.

  ## Examples

      iex> ProjeXpert.Stripe.Customer.get("cus_123")
      {:ok, %{id: "cus_123", object: "customer"}}

  ## Returns

    - `{:ok, customer}` on success.
    - `{:error, reason}` on failure.
  """
  @spec get(String.t()) :: api_response()
  def get(id) do
    ApiClient.get_api("/customers/#{id}")
  end

  @doc """
  Retrieves all customers from Stripe.

  ## Examples

      iex> ProjeXpert.Stripe.Customer.get_all()
      {:ok, [%{id: "cus_123", object: "customer"}, ...]}

  ## Returns

    - `{:ok, [customer]}` on success.
    - `{:error, reason}` on failure.
  """
  @spec get_all() :: all_api_response()
  def get_all do
    ApiClient.get_api("/customers")
  end

  @doc """
  Deletes a customer from Stripe.

  ## Parameters

    - `id`: The ID of the customer to delete.

  ## Examples

      iex> ProjeXpert.Stripe.Customer.delete("cus_123")
      {:ok, %{deleted: true}}

  ## Returns

    - `{:ok, response}` on success.
    - `{:error, reason}` on failure.
  """
  @spec delete(String.t()) :: api_response()
  def delete(id) do
    ApiClient.delete_api("/customers/#{id}")
  end
end
