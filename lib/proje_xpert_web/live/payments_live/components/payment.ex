defmodule ProjeXpertWeb.PaymentsLive.Components.Payment do
  use ProjeXpertWeb, :live_component
  alias ProjeXpert.Tasks
  alias ProjeXpert.Tasks.Payment

  def update(assigns, socket) do
    {:ok, assign(socket, assigns) |> assign(changeset: Tasks.change_payment(%Payment{}))}
  end

  def handle_event("release_payment", %{"payment" => params}, socket) do
    case Tasks.create_payment_with_stripe(socket.assigns.current_user, params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Payment released successfully")
         |> push_navigate(to: ~p"/payments")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong, Please try again.")
         |> push_navigate(to: ~p"/payments")}
    end
  end
end
