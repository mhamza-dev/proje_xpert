defmodule ProjeXpertWeb.PaymentsLive.Index do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.Payment

  def mount(params, _session, %{assigns: assigns} = socket) do
    payments = get_resources_by_role(Payment, assigns.current_user, params)
    {:ok, assign(socket, payments: payments)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _) do
    socket
    |> assign(:page_title, "Payments")
  end

  defp apply_action(socket, :new, %{"task" => id}) do
    socket
    |> assign(:page_title, "Release Payment")
    |> assign(:task, Tasks.get_task!(id))
  end
end
