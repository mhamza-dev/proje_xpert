defmodule ProjeXpertWeb.SettingsLive.Index do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Accounts
  alias ProjeXpert.Accounts.{NotificationPreference, PaymentMethod}
  alias ProjeXpertWeb.SettingsLive.Components.PaymentDelete
  alias ProjeXpertWeb.SettingsLive.Components.PaymentMethod, as: PaymentMethodModal

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    profile_changeset = Accounts.change_user_profile(user)

    notification_preference = get_notification_preference(user)

    np_changeset =
      Accounts.change_notification_preference(notification_preference)

    socket =
      socket
      |> assign(
        current_password: nil,
        email_form_current_password: nil,
        current_email: user.email,
        email_form: to_form(email_changeset),
        password_form: to_form(password_changeset),
        trigger_submit: false,
        profile_changeset: profile_changeset,
        notification_preference: notification_preference,
        np_changeset: np_changeset
      )
      |> allow_upload(:profile,
        max_entries: 1,
        accept: exts_for_profile(),
        max_file_size: 5_000_000
      )

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, _live_action, %{"pm_id" => id, "modal" => "delete_pm"} = params) do
    socket
    |> assign(
      page_title: "Edit Payment Method",
      payment_method: Accounts.get_payment_method!(id),
      current_tab: Map.get(params, "tab"),
      live_action: :delete_pm
    )
  end

  defp apply_action(socket, _live_action, %{"modal" => "new_pm"} = params) do
    socket
    |> assign(
      page_title: "New Payment Method",
      payment_method: %PaymentMethod{},
      current_tab: Map.get(params, "tab"),
      live_action: :new_pm
    )
  end

  defp apply_action(socket, _live_action, params) do
    socket
    |> assign(current_tab: Map.get(params, "tab"))
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/settings/email/#{&1}/confirm")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("validate_profile", %{"profile" => params}, socket) do
    changeset =
      socket.assigns.current_user
      |> Accounts.change_user_profile(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, profile_changeset: changeset)}
  end

  def handle_event("update_profile", %{"profile" => params}, socket) do
    params =
      if Enum.empty?(socket.assigns.uploads.profile.entries) do
        params
      else
        url = List.first(upload_files(socket, :profile))
        Map.put(params, "profile_image", url)
      end

    case Accounts.update_user_profile(socket.assigns.current_user, params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Profile has been updated Successfully")
         |> push_navigate(to: ~p"/settings")}

      {:error, changeset} ->
        {:noreply, assign(socket, profile_changeset: changeset)}
    end
  end

  def handle_event("validate_np", %{"np" => params}, socket) do
    changeset =
      socket.assigns.notification_preference
      |> Accounts.change_notification_preference(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, np_changeset: changeset)}
  end

  def handle_event("update_np", %{"np" => params}, socket) do
    case upsert_np(socket.assigns.current_user, create_np_params(params)) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Notification Preferences has been updated Successfully")
         |> push_navigate(to: ~p"/settings")}

      {:error, changeset} ->
        {:noreply, assign(socket, np_changeset: changeset)}
    end
  end

  defp get_notification_preference(%{id: id, notification_preference: nil}),
    do: %NotificationPreference{user_id: id}

  defp get_notification_preference(%{notification_preference: np}), do: np

  defp upsert_np(current_user, params) do
    if current_user.notification_preference do
      Accounts.update_notification_preference(current_user.notification_preference, params)
    else
      Accounts.create_notification_preference(params)
    end
  end

  defp create_np_params(params), do: default_params() |> Map.merge(params)

  defp default_params, do: %{"email" => false, "sms" => false, "push" => false}
end
