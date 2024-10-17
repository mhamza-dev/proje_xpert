defmodule ProjeXpertWeb.BidsLive.Index do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.{Bid, Project, Task}

  def mount(params, _session, %{assigns: assigns} = socket) do
    bids = get_resources_by_role(Bid, assigns.current_user, params, %{})

    {:ok,
     socket
     |> assign(current_tab: Map.get(params, "tab"))
     |> assign(:bids, bids)}
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
      projects: get_resources_by_role(Project, socket.assigns.current_user),
      task: %Task{}
    )
  end

  def handle_event("search", %{"search" => search}, %{assigns: assigns} = socket) do
    bids =
      get_resources_by_role(
        Bid,
        assigns.current_user,
        fetch_tab_param(assigns.current_tab),
        search
      )

    {:noreply, socket |> assign(:bids, bids)}
  end

  def handle_event("set_status", %{"id" => id, "status" => "accepted"}, socket) do
    with %Bid{} = bid <- Tasks.get_bid!(id),
         {:ok, bid} <- Tasks.update_bid(bid, %{"status" => "accepted"}),
         %Task{} = task <- Tasks.get_task!(bid.task_id),
         {:ok, _} <-
           Tasks.create_worker_project(%{
             "task_id" => task.project_id,
             "worker_id" => bid.worker_id
           }),
         {:ok, _} <-
           Tasks.create_worker_task(%{"task_id" => bid.task_id, "worker_id" => bid.worker_id}) do
      {:noreply,
       put_flash(socket, :info, "Bid has been update to #{camel_case_string("accepted")}")
       |> redirect(to: get_parent_url_by_params(socket.assigns.current_tab))}
    else
      _ ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Something went wrong while update to #{camel_case_string("accepted")}"
         )
         |> redirect(to: get_parent_url_by_params(socket.assigns.current_tab))}
    end
  end

  def handle_event("set_status", %{"id" => id, "status" => status}, socket) do
    with %Bid{} = bid <- Tasks.get_bid!(id),
         {:ok, _bid} <- Tasks.update_bid(bid, %{"status" => status}) do
      {:noreply,
       put_flash(socket, :info, "Bid has been update to #{camel_case_string(status)}")
       |> redirect(to: get_parent_url_by_params(socket.assigns.current_tab))}
    else
      _ ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Something went wrong while update to #{camel_case_string(status)}"
         )
         |> redirect(to: get_parent_url_by_params(socket.assigns.current_tab))}
    end
  end

  defp get_parent_url_by_params(current_tab) do
    if is_nil(current_tab) do
      ~p"/bids"
    else
      ~p"/bids?tab=#{current_tab}"
    end
  end
end
