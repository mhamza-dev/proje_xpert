defmodule ProjeXpert.Stripe.Charge do
  alias ProjeXpert.Stripe.ApiClient

  @type create :: %{
          # Amount in cents
          required(:amount) => integer(),
          required(:currency) => String.t(),
          # Payment source (e.g., card token)
          optional(:source) => String.t(),
          optional(:description) => String.t(),
          optional(:metadata) => %{String.t() => String.t()},
          # Whether to capture the charge immediately
          optional(:capture) => boolean(),
          # Customer ID if applicable
          optional(:customer) => String.t()
        }

  @type charge :: %{
          required(:id) => String.t(),
          required(:object) => String.t(),
          required(:amount) => integer(),
          required(:currency) => String.t(),
          required(:created) => integer(),
          required(:status) => String.t(),
          optional(:description) => String.t(),
          optional(:metadata) => %{String.t() => String.t()},
          optional(:payment_method) => String.t(),
          optional(:customer) => String.t(),
          optional(:refunds) => %{
            required(:object) => String.t(),
            required(:data) => [map()],
            optional(:has_more) => boolean(),
            optional(:total_count) => integer(),
            optional(:url) => String.t()
          }
        }

  @type all_api_response :: {:ok, [charge()]} | {:error, any()}
  @type api_response :: {:ok, charge()} | {:error, any()}

  @spec create(create()) :: api_response()
  def create(params) do
    ApiClient.post_api("/charges", params)
  end

  @spec get(String.t()) :: api_response()
  def get(id) do
    ApiClient.get_api("/charges/#{id}")
  end

  @spec get_all() :: all_api_response()
  def get_all do
    ApiClient.get_api("/charges")
  end

  @spec capture(String.t(), map()) :: api_response()
  def capture(id, params \\ %{}) do
    ApiClient.post_api("/charges/#{id}/capture", params)
  end

  @spec refund(String.t(), map()) :: api_response()
  def refund(id, params \\ %{}) do
    ApiClient.post_api("/charges/#{id}/refunds", params)
  end
end
