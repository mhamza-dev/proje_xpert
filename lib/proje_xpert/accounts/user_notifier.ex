defmodule ProjeXpert.Accounts.UserNotifier do
  use Phoenix.Swoosh,
    view: ProjeXpertWeb.View.Emails,
    layout: {ProjeXpertWeb.View.Emails, :layout}

  import Swoosh.Email
  alias ProjeXpertWeb.LiveHelpers
  alias ProjeXpert.Mailer

  # Delivers the email using the application mailer.
  defp deliver(email) do
    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    new()
    |> to({LiveHelpers.full_name(user), user.email})
    |> from({"ProjeXpert", System.get_env("SENDER_MAIL")})
    |> subject("Confirm your account.")
    |> render_body("confirm_email.html", url: url)
    |> deliver()
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    new()
    |> to({LiveHelpers.full_name(user), user.email})
    |> from({"ProjeXpert", System.get_env("SENDER_MAIL")})
    |> subject("Reset your password.")
    |> render_body("reset_password.html", url: url)
    |> deliver()
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    new()
    |> to({LiveHelpers.full_name(user), user.email})
    |> from({"ProjeXpert", System.get_env("SENDER_MAIL")})
    |> subject("Reset your password.")
    |> render_body("req_update_email.html", url: url)
    |> deliver()
  end

  @doc """
  Deliver new feature updates.
  """
  def deliver_update_new_features(user, image, features) do
    new()
    |> to({LiveHelpers.full_name(user), user.email})
    |> from({"ProjeXpert", System.get_env("SENDER_MAIL")})
    |> subject("Reset your password.")
    |> render_body("new_feature.html", image: image, features: features)
    |> deliver()
  end
end
