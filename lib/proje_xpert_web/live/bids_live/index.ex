defmodule ProjeXpertWeb.BidsLive.Index do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.{Bid, Task}

  def mount(params, _session, %{assigns: assigns} = socket) do
    bids = get_resources_by_tab(params, Tasks.list_client_bids(assigns.current_user.id))

    {:ok,
     socket
     |> assign(current_tab: Map.get(params, "tab"))
     |> stream(:bids, bids)}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    bid = Tasks.get_bid!(id)

    socket
    |> assign(page_title: "Edit Bid", bid: bid, project: bid.task.project)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Bids")
    |> assign(:project, nil)
  end

  defp apply_action(socket, :bids_new_task, _params) do
    socket
    |> assign(
      page_title: "New Task",
      projects: get_projects_by_role(socket.assigns.current_user),
      task: %Task{}
    )
  end
end
