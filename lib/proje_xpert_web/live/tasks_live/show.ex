defmodule ProjeXpertWeb.TasksLive.Show do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.Bid

  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     assign(socket,
       task: Tasks.get_task!(id),
       bid: %Bid{},
       changeset: Tasks.change_bid(%Bid{})
     )
     |> allow_upload(:cv,
       max_entries: 1,
       accept: ~w(.pdf),
       max_file_size: 2_0000
     )}
  end

  def handle_event("validate-bid", %{"bid" => bid_params}, socket) do
    changeset =
      socket.assigns.bid
      |> Tasks.change_bid(bid_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end
end
