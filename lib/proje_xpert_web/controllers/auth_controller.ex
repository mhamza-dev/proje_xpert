defmodule ProjeXpertWeb.AuthController do
  use ProjeXpertWeb, :controller

  alias ProjeXpert.Accounts
  alias ProjeXpertWeb.UserAuth

  require Logger

  plug(Ueberauth)

  # def request(conn, %{"provider" => provider}) do
  #   if provider == "google" do
  #     redirect(conn, to: Ueberauth.Strategy.Helpers.callback_url(conn))
  #   end
  # end
  def request(conn, %{"provider" => provider}) do
    [role | [provider]] = String.split(provider, "_", parts: 2)
    conn = assign(conn, :role, role)

    if provider == "google" do
      redirect(conn, to: Ueberauth.Strategy.Helpers.callback_url(conn))
    else
      conn
      |> put_flash(:error, "Unsupported provider: #{provider}")
      |> redirect(to: "/")
    end
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, %{"provider" => provider}) do
    email = auth.info.email

    case Accounts.get_user_by_email(email) do
      nil ->
        # User does not exist, so create a new user
        user_params = %{
          email: email,
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          provider: provider,
          role: :worker
        }

        case Accounts.register_oauth_user(user_params) do
          {:ok, user} ->
            UserAuth.log_in_user(conn, user)

          {:error, changeset} ->
            Logger.error("Failed to create user #{inspect(changeset)}.")

            conn
            |> put_flash(:error, "Failed to create user.")
            |> redirect(to: ~p"/")
        end

      user ->
        # User exists, update session or other details if necessary
        UserAuth.log_in_user(conn, user)
    end
  end
end
