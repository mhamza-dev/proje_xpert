defmodule ProjeXpertWeb.NotificationBell do
  use ProjeXpertWeb, :live_component

  alias ProjeXpert.Accounts
  alias ProjeXpert.Accounts.Notification

  def render(assigns) do
    ~H"""
    <div class="relative" x-data="{ open: false }">
      <svg
        @click="open = !open"
        @click.outside="open = false"
        type="button"
        class="w-9 h-9 text-gray-800"
        aria-hidden="true"
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        fill="none"
        viewBox="0 0 24 24"
      >
        <path
          stroke="currentColor"
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="1.5"
          d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
        />
        <div
          :if={@notification_count > 0 and @notification_count <= 9}
          class="absolute top-0 right-[-5px]"
        >
          <div class="w-4 h-4 p-1 bg-red-400 rounded-full flex items-center justify-center text-white text-xs font-bold">
            <%= @notification_count %>
          </div>
        </div>
        <div :if={@notification_count > 9} class="absolute top-0 right-[-5px]">
          <div class="w-5 h-5 p-1 bg-red-400 rounded-full flex items-center justify-center text-white text-xs font-bold">
            <%= "9+" %>
          </div>
        </div>
      </svg>
      <div
        x-show="open"
        class="absolute z-[60] right-0 mt-2 w-96 rounded-md bg-white py-2 px-3 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
      >
        <div :if={Enum.empty?(@drawer_notifications)} class="flex items-center justify-between">
          <p class="text-gray-800 text-md">No Notifications Yet</p>
        </div>
        <div>
          <div
            phx-click="mark_all_as_read"
            phx-target={@myself}
            class="text-sm text-right cursor-pointer text-gray-500 hover:text-blue-500 hover:underline"
          >
            Mark all as read
          </div>
          <div
            :for={notification <- @drawer_notifications}
            :if={!Enum.empty?(@drawer_notifications)}
            class={
              [
                "flex items-center justify-between p-4 my-1 transition duration-200 ease-in-out group rounded-md",
                !notification.is_read? && "bg-blue-100"
              ]
              |> combine_classes()
            }
          >
            <div class="flex-1 space-y-1">
              <div
                phx-click="goto_notification"
                phx-value-id={notification.id}
                phx-target={@myself}
                class="text-gray-800 text-sm cursor-pointer"
              >
                <%= raw(notification.message) %>
              </div>
              <div class="flex items-center justify-between">
                <p class="text-sm text-gray-500 text-right">
                  <%= relative_time(notification.inserted_at) %>
                </p>
                <button
                  :if={!notification.is_read?}
                  phx-click="mark_as_read"
                  phx-value-id={notification.id}
                  phx-target={@myself}
                  class="flex items-center invisible group-hover:visible text-gray-500 hover:text-green-500 transition duration-200 ease-in-out"
                >
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-5 w-5"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M5 13l4 4L19 7"
                    />
                  </svg>
                  <span class="text-sm">Mark as read</span>
                </button>
              </div>
            </div>
          </div>
          <div class="flex justify-end">
            <.link
              navigate={~p"/settings?tab=notifications"}
              class="text-sm text-gray-500 hover:text-blue-500 hover:underline"
            >
              See All
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("mark_as_read", %{"id" => id}, socket) do
    with %Notification{} = notification <- Accounts.get_notification!(id),
         {:ok, _} <- Accounts.update_notification(notification, %{"is_read?" => true}) do
      send(self(), {:notification, socket.assigns.current_user.id, notification})
      {:noreply, socket}
    else
      _ ->
        {:noreply, socket}
    end
  end
end
