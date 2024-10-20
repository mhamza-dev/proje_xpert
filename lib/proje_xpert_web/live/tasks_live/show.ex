defmodule ProjeXpertWeb.TasksLive.Show do
  require Protocol
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.Bid

  Protocol.derive(Jason.Encoder, Cloudex.UploadedImage,
    only: [:public_id, :secure_url, :format, :created_at]
  )

  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     assign(socket,
       task: Tasks.get_task!(id),
       bid: %Bid{},
       changeset: Tasks.change_bid(%Bid{})
     )
     |> allow_upload(:cv,
       max_entries: 2,
       accept: ~w(.pdf),
       max_file_size: 5_000_000
     )}
  end

  def handle_params(%{"source" => source, "title" => title}, _uri, socket) do
    {:noreply, assign(socket, show_attachment: true, page_title: title, source: source)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, assign(socket, show_attachment: false)}
  end

  def handle_event("cancel_cv", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :cv, ref)}
  end

  def handle_event("validate_bid", %{"bid" => bid_params}, socket) do
    changeset =
      socket.assigns.bid
      |> Tasks.change_bid(bid_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("create_bid", %{"bid" => bid_params}, socket) do
    urls = upload_files(socket, :cv)

    if Enum.any?(urls, &(&1 == :error)) do
      {:noreply,
       socket
       |> put_flash(:error, "Something went wrong while Uploading the File")
       |> push_navigate(to: ~p"/tasks/#{socket.assigns.task.id}/show")}
    else
      bid_params |> Map.put("attached_files", urls) |> create_bid(socket)
    end
  end

  def create_bid(bid_params, %{assigns: assigns} = socket) do
    case Tasks.create_bid(bid_params) do
      {:ok, bid} ->
        Phoenix.PubSub.broadcast!(ProjeXpert.PubSub, "bids", {:bid_created})

        {:noreply,
         socket
         |> put_flash(:info, "Bid submitted successfully")
         |> push_navigate(to: ~p"/tasks/#{bid.task_id}/show")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong while Bidding")
         |> push_navigate(to: ~p"/tasks/#{assigns.task.id}/show")}
    end
  end
end
