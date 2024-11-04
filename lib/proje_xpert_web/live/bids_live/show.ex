defmodule ProjeXpertWeb.BidsLive.Show do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.Task

  def mount(%{"id" => id}, _session, socket) do
    {:ok, assign(socket, bid: Tasks.get_bid!(id))}
  end

  def handle_params(%{"source" => source, "title" => title}, _uri, socket) do
    {:noreply, assign(socket, show_attachment: true, page_title: title, source: source)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, show_attachment: false)}
  end

  def handle_event("accept-bid", _unsigned_params, socket) do
    bid = socket.assigns.bid

    with {:ok, _bid} <- Tasks.update_bid(bid, %{"status" => "accepted"}),
         {:ok, _} <- is_user_already_in_project(bid),
         %Task{} = task <- Tasks.get_task!(bid.task_id),
         {:ok, _} <- Tasks.update_task(task, %{"worker_id" => bid.worker_id}) do
      {:noreply,
       socket
       |> put_flash(:info, "Bid accepted successfully")
       |> push_navigate(to: ~p"/bids/#{bid.id}/show")}
    else
      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong while accepting the bid")
         |> push_navigate(to: ~p"/bids/#{bid.id}/show")}
    end
  end
end
