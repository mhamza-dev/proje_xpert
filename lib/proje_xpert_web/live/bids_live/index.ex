defmodule ProjeXpertWeb.BidsLive.Index do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Accounts
  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.{Bid, Project, Task}

  def mount(params, _session, %{assigns: assigns} = socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(ProjeXpert.PubSub, "bids")

    {:ok,
     socket
     |> assign(current_tab: Map.get(params, "tab"))
     |> assign(:bids, get_resources_by_role(Bid, assigns.current_user, params))}
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
        Map.merge(fetch_tab_param(assigns.current_tab), search)
      )

    {:noreply, socket |> assign(:bids, bids)}
  end

  def handle_event("set_status", %{"id" => id, "status" => "accepted"}, socket) do
    with %Bid{} = bid <- Tasks.get_bid!(id),
         {:ok, bid} <- Tasks.update_bid(bid, %{"status" => "accepted"}),
         %Task{} = task <- Tasks.get_task!(bid.task_id),
         {:ok, _} <- is_user_already_in_project(bid),
         {:ok, _} <- Tasks.update_task(task, %{"freelancer_id" => bid.freelancer_id}),
         {:ok, notification} <- bid_accept_notification(task, bid) do
      send(self(), {:notification, bid.freelancer_id, notification})
      send(self(), {:update_bid_list})

      {:noreply,
       put_flash(socket, :info, "Bid has been update to #{camel_case_string("accepted")}")}
    else
      _ ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Something went wrong while update to #{camel_case_string("accepted")}"
         )}
    end
  end

  def handle_event("set_status", %{"id" => id, "status" => status}, socket) do
    with %Bid{} = bid <- Tasks.get_bid!(id),
         {:ok, _bid} <- Tasks.update_bid(bid, %{"status" => status}) do
      send(self(), {:update_bid_list})
      {:noreply, put_flash(socket, :info, "Bid has been update to #{camel_case_string(status)}")}
    else
      _ ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Something went wrong while update to #{camel_case_string(status)}"
         )}
    end
  end

  def handle_info({:update_bid_list}, %{assigns: assigns} = socket) do
    {:noreply,
     assign(socket,
       bids:
         get_resources_by_role(
           Bid,
           assigns.current_user,
           fetch_tab_param(assigns.current_tab)
         )
     )}
  end

  defp bid_accept_notification(task, bid) do
    Accounts.create_notification(%{
      "type" => "push",
      "user_id" => bid.freelancer_id,
      "link" => "/bids/#{bid.id}/show",
      "message" => """
        <p><strong>#{full_name(task.project.client)}</strong> has been accepted your bid against the task #{task.title}. and added you in the project #{task.project.title} </p>
      """
    })
  end
end
