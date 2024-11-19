defmodule ProjeXpert.Stripe.ApiClient do
  use HTTPoison.Base

  @type response :: {:ok, map()} | {:error, any()}

  @spec get_api(String.t()) :: response()
  def get_api(url) do
    case HTTPoison.get(base_url(url), headers()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decode_response(body)

      {:error, %HTTPoison.Error{} = error} ->
        {:error, error}
    end
  end

  @spec post_api(String.t(), map()) :: response()
  def post_api(url, body) do
    case HTTPoison.post(base_url(url), make_form_encoded(body), headers()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decode_response(body)

      {:ok, %HTTPoison.Response{status_code: _status_code, body: body}} ->
        %{error: error} = decode_response!(body)
        {:error, error}
    end
  end

  @spec put_api(String.t(), map()) :: response()
  def put_api(url, body) do
    case HTTPoison.put(base_url(url), make_form_encoded(body), headers()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decode_response(body)

      {:ok, %HTTPoison.Response{status_code: _status_code, body: body}} ->
        %{error: error} = decode_response!(body)
        {:error, error}
    end
  end

  @spec patch_api(String.t(), map()) :: response()
  def patch_api(url, body) do
    case HTTPoison.patch(base_url(url), make_form_encoded(body), headers()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decode_response(body)

      {:ok, %HTTPoison.Response{status_code: _status_code, body: body}} ->
        %{error: error} = decode_response!(body)
        {:error, error}
    end
  end

  @spec delete_api(String.t()) :: response()
  def delete_api(url) do
    case HTTPoison.delete(base_url(url), headers()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decode_response(body)

      {:ok, %HTTPoison.Response{status_code: _status_code, body: body}} ->
        %{error: error} = decode_response!(body)
        {:error, error}
    end
  end

  @spec decode_response(any()) :: {:ok, map()} | {:error, String.t()}
  defp decode_response!(body), do: Morphix.atomorphiform!(Jason.decode!(body))

  @spec decode_response(any()) :: {:ok, map()} | {:error, String.t()}
  defp decode_response(body) do
    case Jason.decode(body) do
      {:ok, decoded_data} -> {:ok, Morphix.atomorphiform!(decoded_data)}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec headers() :: list()
  def headers do
    [
      {"Authorization", "Bearer #{System.get_env("STRIPE_SECRET_KEY")}"},
      # {"Content-Type", "application/json"}
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]
  end

  @spec base_url(String.t()) :: String.t()
  def base_url(url) do
    "https://api.stripe.com/v1" <> url
  end

  def make_form_encoded(body) do
    body
    |> flatten_map()
    |> URI.encode_query()
  end

  def flatten_map(map) do
    flatten_map(map, "")
  end

  # Private recursive function for flattening
  defp flatten_map(%{} = map, prefix) do
    map
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      full_key = if prefix == "", do: "#{key}", else: "#{prefix}[#{key}]"
      Map.merge(acc, flatten_map(value, full_key))
    end)
  end

  # Base case: handles non-map values
  defp flatten_map(value, prefix) when is_binary(prefix), do: %{prefix => value}
end
