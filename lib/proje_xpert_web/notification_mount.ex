defmodule ProjeXpertWeb.NotificationMount do
  alias ProjeXpert.Accounts

  def on_mount(_, _params, _session, socket) do
    notifications = Accounts.list_notifications_by_user(socket.assigns.current_user.id)

    {:cont,
     Phoenix.Component.assign(
       socket,
       :notification_count,
       Accounts.total_notifications(socket.assigns.current_user.id)
     )
     |> Phoenix.Component.assign(:drawer_notifications, Enum.take(notifications, 4))
     |> Phoenix.Component.assign(:all_notifications, notifications)}
  end
end
