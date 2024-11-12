defmodule ProjeXpertWeb.SettingsLive.Components.PaymentDelete do
  alias ProjeXpert.Accounts
  use ProjeXpertWeb, :live_component

  def update(%{payment_method: _pm} = assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def handle_event("confirm_delete", _params, socket) do
    case Accounts.delete_payment_method(socket.assigns.payment_method) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Payment method deleted successfully")
         |> push_navigate(to: ~p"/settings?tab=payment")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Something went wrong while delete, Please try again.")
         |> push_navigate(to: ~p"/settings?tab=payment")}
    end
  end
end
