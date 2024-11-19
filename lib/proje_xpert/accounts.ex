defmodule ProjeXpert.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  import ProjeXpertWeb.LiveHelpers
  alias ProjeXpert.Repo

  alias ProjeXpert.Accounts.{NotificationPreference, PaymentMethod, User, UserToken, UserNotifier}
  alias ProjeXpert.Stripe.PaymentMethod, as: StripePM
  alias ProjeXpert.Stripe.Customer, as: StripeCustomer

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def list_users_by_ids(ids) do
    from(u in User, where: u.id in ^ids) |> Repo.all()
  end

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def register_oauth_user(attrs) do
    %User{}
    |> User.oauth_registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: true)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  def update_user(user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/settings/email/#{&1}/confirm"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user profile.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_profile(user, attrs \\ %{}) do
    User.profile_changeset(user, attrs)
  end

  def update_user_profile(user, attrs) do
    User.profile_changeset(user, attrs) |> Repo.update()
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query) |> Repo.preload([:notification_preference, :notifications, :payment_methods])
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(%{"token" => token} = params) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, user} <- update_user_profile(user, params),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &url(~p"/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Returns the list of notification_preferences.

  ## Examples

      iex> list_notification_preferences()
      [%NotificationPreference{}, ...]

  """
  def list_notification_preferences do
    Repo.all(NotificationPreference)
  end

  @doc """
  Gets a single notification_preference.

  Raises `Ecto.NoResultsError` if the Notification preference does not exist.

  ## Examples

      iex> get_notification_preference!(123)
      %NotificationPreference{}

      iex> get_notification_preference!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification_preference!(id), do: Repo.get!(NotificationPreference, id)

  @doc """
  Creates a notification_preference.

  ## Examples

      iex> create_notification_preference(%{field: value})
      {:ok, %NotificationPreference{}}

      iex> create_notification_preference(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification_preference(attrs \\ %{}) do
    %NotificationPreference{}
    |> NotificationPreference.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a notification_preference.

  ## Examples

      iex> update_notification_preference(notification_preference, %{field: new_value})
      {:ok, %NotificationPreference{}}

      iex> update_notification_preference(notification_preference, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification_preference(%NotificationPreference{} = notification_preference, attrs) do
    notification_preference
    |> NotificationPreference.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notification_preference.

  ## Examples

      iex> delete_notification_preference(notification_preference)
      {:ok, %NotificationPreference{}}

      iex> delete_notification_preference(notification_preference)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification_preference(%NotificationPreference{} = notification_preference) do
    Repo.delete(notification_preference)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification_preference changes.

  ## Examples

      iex> change_notification_preference(notification_preference)
      %Ecto.Changeset{data: %NotificationPreference{}}

  """
  def change_notification_preference(
        %NotificationPreference{} = notification_preference,
        attrs \\ %{}
      ) do
    NotificationPreference.changeset(notification_preference, attrs)
  end

  alias ProjeXpert.Accounts.Notification

  @doc """
  Returns the list of notifications.

  ## Examples

      iex> list_notifications()
      [%Notification{}, ...]

  """
  def list_notifications do
    Repo.all(Notification)
  end

  @doc """
  Gets a single notification.

  Raises `Ecto.NoResultsError` if the Notification does not exist.

  ## Examples

      iex> get_notification!(123)
      %Notification{}

      iex> get_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification!(id), do: Repo.get!(Notification, id)

  @doc """
  Creates a notification.

  ## Examples

      iex> create_notification(%{field: value})
      {:ok, %Notification{}}

      iex> create_notification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a notification.

  ## Examples

      iex> update_notification(notification, %{field: new_value})
      {:ok, %Notification{}}

      iex> update_notification(notification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notification.

  ## Examples

      iex> delete_notification(notification)
      {:ok, %Notification{}}

      iex> delete_notification(notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification changes.

  ## Examples

      iex> change_notification(notification)
      %Ecto.Changeset{data: %Notification{}}

  """
  def change_notification(%Notification{} = notification, attrs \\ %{}) do
    Notification.changeset(notification, attrs)
  end

  def unread_notifications(user_id) do
    from(
      n in Notification,
      where: n.user_id == ^user_id and n.is_read? == ^false,
      order_by: [desc: n.inserted_at]
    )
    |> Repo.aggregate(:count)
  end

  def total_notifications(user_id) do
    from(
      n in Notification,
      where: n.user_id == ^user_id and n.is_read? == ^false,
      order_by: [desc: n.inserted_at]
    )
    |> Repo.aggregate(:count)
  end

  def list_notifications_by_user(user_id, notifications_limit \\ nil) do
    notifications =
      from(
        n in Notification,
        where: n.user_id == ^user_id,
        order_by: [desc: n.inserted_at]
      )
      |> preload(:user)

    notifications =
      if is_nil(notifications_limit),
        do: notifications,
        else: limit(notifications, ^notifications_limit)

    Repo.all(notifications)
  end

  @doc """
  Returns the list of payment_methods.

  ## Examples

      iex> list_payment_methods()
      [%PaymentMethod{}, ...]

  """
  def list_payment_methods do
    Repo.all(PaymentMethod)
  end

  @doc """
  Gets a single payment_method.

  Raises `Ecto.NoResultsError` if the Payment method does not exist.

  ## Examples

      iex> get_payment_method!(123)
      %PaymentMethod{}

      iex> get_payment_method!(456)
      ** (Ecto.NoResultsError)

  """
  def get_payment_method!(id), do: Repo.get!(PaymentMethod, id)

  @doc """
  Creates a payment_method.

  ## Examples

      iex> create_payment_method(%{field: value})
      {:ok, %PaymentMethod{}}

      iex> create_payment_method(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_payment_method(attrs \\ %{}) do
    %PaymentMethod{}
    |> PaymentMethod.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a payment_method.

  ## Examples

      iex> update_payment_method(payment_method, %{field: new_value})
      {:ok, %PaymentMethod{}}

      iex> update_payment_method(payment_method, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_payment_method(%PaymentMethod{} = payment_method, attrs) do
    payment_method
    |> PaymentMethod.create_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a payment_method.

  ## Examples

      iex> delete_payment_method(payment_method)
      {:ok, %PaymentMethod{}}

      iex> delete_payment_method(payment_method)
      {:error, %Ecto.Changeset{}}

  """
  def delete_payment_method(%PaymentMethod{} = payment_method) do
    Repo.delete(payment_method)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking payment_method changes.

  ## Examples

      iex> change_payment_method(payment_method)
      %Ecto.Changeset{data: %PaymentMethod{}}

  """
  def change_payment_method(%PaymentMethod{} = payment_method, attrs \\ %{}) do
    PaymentMethod.validate_changeset(payment_method, attrs)
  end

  def create_payment_method_with_stripe(attrs \\ %{}) do
    with %User{} = user <- get_user!(attrs["user_id"]),
         {:ok, %{id: id}} <- create_stripe_customer_if_not_exist(user),
         {:ok, _user} <- update_user(user, %{"stripe_customer_id" => id}),
         {:ok, spm} <- StripePM.create(spm_params(attrs)),
         {:ok, _spm} <- StripePM.attach(spm.id, %{customer: id}),
         {:ok, payment_method} <- create_payment_method(pm_params(attrs, spm)) do
      {:ok, payment_method}
    else
      {:error, changeset} ->
        {:error, changeset}

      _ ->
        {:error, "Unknown error occurred"}
    end
  end

  defp create_stripe_customer_if_not_exist(%{stripe_customer_id: nil} = user) do
    StripeCustomer.create(%{
      email: user.email,
      name: full_name(user)
    })
  end

  defp create_stripe_customer_if_not_exist(%{stripe_customer_id: id}), do: {:ok, %{id: id}}

  defp pm_params(attrs, spm) do
    Map.merge(attrs, %{
      "brand" => spm.card.brand,
      "card_id" => spm.id,
      "default" => true,
      "last_four_digits" => spm.card.last4
    })
  end

  # defp spm_params(attrs) do
  #   [month, year] = String.split(attrs["expiry"], "/")

  #   %{
  #     type: "card",
  #     card: %{
  #       number: attrs["last_four_digits"],
  #       exp_month: String.to_integer(month),
  #       exp_year: String.to_integer(year),
  #       cvc: attrs["cvv"]
  #     }
  #   }
  # end

  defp spm_params(attrs) do
    %{
      type: "card",
      card: %{
        token: get_card_token(attrs["last_four_digits"])
      }
    }
  end

  def get_card_token(key) do
    Map.get(
      %{
        "4242424242424242" => "tok_visa",
        "4000056655665556" => "tok_visa_debit",
        "5555555555554444" => "tok_mastercard",
        "2223003122003222" => "tok_mastercard_debit",
        "378282246310005" => "tok_amex",
        "6011111111111117" => "tok_discover"
      },
      key,
      "tok_visa"
    )
  end
end
