defmodule ProjeXpert.Stripe.Token do
  @moduledoc """
  A module for interacting with the Stripe API to create tokens.
  """
  alias ProjeXpert.Stripe.ApiClient

  @type card_params :: %{
          required(:card) => %{
            required(:number) => String.t(),
            required(:exp_month) => integer(),
            required(:exp_year) => integer(),
            required(:cvc) => String.t(),
            optional(:name) => String.t(),
            optional(:address_line1) => String.t(),
            optional(:address_line2) => String.t(),
            optional(:address_city) => String.t(),
            optional(:address_state) => String.t(),
            optional(:address_zip) => String.t(),
            optional(:address_country) => String.t()
          }
        }

  @type token_response :: {:ok, map()} | {:error, map()}

  @doc """
  Creates a token for a credit card.

  ## Parameters

    - `card_params`: A map containing the card details.

  ## Examples

      iex> Stripe.Token.create(%{
      ...>   number: "4000XXXXXXXXXXXX",
      ...>   exp_month: 11,
      ...>   exp_year: 2025,
      ...>   cvc: "123"
      ...> })
      {:ok, %{id: "tok_1I..."}}

  """
  @spec create(card_params()) :: token_response()
  def create(card_params) do
    ApiClient.post_api("/tokens", card_params)
  end
end
