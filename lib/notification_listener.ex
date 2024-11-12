defmodule NotificationListener do
  alias ProjeXpert.Accounts
  alias ProjeXpert.Accounts.Notification

  def listener do
    quote do
      def handle_info({:notification, user_id, notification}, socket) do
        if socket.assigns.current_user.notification_preference.push do
          {:noreply,
           socket
           |> assign(
             notification_count: Accounts.unread_notifications(socket.assigns.current_user.id),
             all_notifications:
               Accounts.list_notifications_by_user(socket.assigns.current_user.id),
             drawer_notifications:
               Accounts.list_notifications_by_user(socket.assigns.current_user.id, 4)
           )}
        else
          {:noreply, socket}
        end
      end
    end
  end

  # def read_notification do
  #   quote do
  #     def handle_info({:read_notification, id}, socket) do
  #       with %Notification{} = notification <- Accounts.get_notification!(id),
  #            {:ok, _} <- Accounts.update_notification(notification, %{"is_read?" => true}) do
  #         send(self(), {:notification, socket.assigns.current_user.id, notification})
  #         {:noreply, socket}
  #       else
  #         _ ->
  #           {:noreply, put_flash(socket, :error, "Something went wrong!!!")}
  #       end
  #     end
  #   end
  # end

  def goto_notif_event do
    quote do
      def handle_event("goto_notification", %{"id" => id}, socket) do
        with %Notification{} = notification <- Accounts.get_notification!(id),
             {:ok, _} <- Accounts.update_notification(notification, %{"is_read?" => true}) do
          send(self(), {:notification, socket.assigns.current_user.id, notification})
          {:noreply, redirect(socket, to: notification.link)}
        else
          _ ->
            {:noreply, socket}
        end
      end
    end
  end

  def mark_all_as_read_event do
    quote do
      def handle_event("mark_all_as_read", _, socket) do
        socket.assigns.current_user.id
        |> Accounts.list_notifications_by_user()
        |> Enum.each(fn n -> Accounts.update_notification(n, %{"is_read?" => true}) end)

        send(self(), {:notification, socket.assigns.current_user.id, "notifications"})

        {:noreply, socket}
      end
    end
  end
end
