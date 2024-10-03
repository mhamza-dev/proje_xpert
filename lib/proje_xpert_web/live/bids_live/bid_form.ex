defmodule ProjeXpertWeb.ProjectsLive.BidForm do
  alias ProjeXpert.Accounts
  use ProjeXpertWeb, :live_component

  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.Bid

  def update(%{bid: bid} = assigns, socket) do
    changeset = Tasks.change_bid(bid, %{})
    {:ok, socket |> assign(assigns) |> assign(changeset: changeset)}
  end

  def handle_event("validate", %{"bid" => bid_params}, socket) do
    changeset =
      socket.assigns.bid
      |> Tasks.change_bid(bid_params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("save", %{"bid" => bid_params}, socket) do
    case socket.assigns.action do
      :new ->
        create_bid(bid_params, socket)

      :edit ->
        update_bid(bid_params, socket)
    end
  end

  defp create_bid(bid_params, socket) do
    case Tasks.create_bid(bid_params) do
      {:ok, _bid} ->
        # Phoenix.PubSub.broadcast!(
        #   ProjeXpert.PubSub,
        #   "project:#{socket.assigns.project.id}",
        #   {:bid, socket.assigns.project.id}
        # )

        {:noreply,
         socket
         |> put_flash(:info, "bid created successfully")
         |> push_navigate(to: ~p"/bids")}

      {:error, changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end

  defp update_bid(bid_params, socket) do
    case Tasks.update_bid(socket.assigns.bid, bid_params) do
      {:ok, _bid} ->
        # Phoenix.PubSub.broadcast!(
        #   ProjeXpert.PubSub,
        #   "project:#{socket.assigns.project.id}",
        #   {:bid, socket.assigns.project.id}
        # )

        {:noreply,
         socket
         |> put_flash(:info, "bid updated successfully")
         |> push_navigate(to: ~p"/bids")}

      {:error, changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end

  defp get_bidder_option(bid) do
    case Accounts.get_user!(bid.worker_id) do
      %Accounts.User{} = user ->
        [{full_name(user), user.id}]

      _ ->
        []
    end
  end
end
