defmodule ProjeXpertWeb.SettingsLive.Components.PaymentMethod do
  use ProjeXpertWeb, :live_component
  alias ProjeXpert.Accounts

  def update(%{payment_method: payment_method} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(changeset: Accounts.change_payment_method(payment_method))}
  end

  def handle_event("validate", %{"payment_method" => params}, socket) do
    changeset =
      socket.assigns.payment_method
      |> Accounts.change_payment_method(params)
      |> Map.put(:action, :validate)

    {:noreply, socket |> assign(changeset: changeset)}
  end

  def handle_event("save", %{"payment_method" => params}, socket) do
    case Accounts.create_payment_method_with_stripe(params) do
      {:ok, _payment_method} ->
        {:noreply,
         socket
         |> put_flash(:info, "Payment method added successfully")
         |> push_navigate(to: ~p"/settings?tab=payment")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}

      {:error, msg} ->
        {:noreply,
         socket
         |> put_flash(:error, msg)
         |> push_navigate(to: ~p"/settings?tab=payment")}
    end
  end
end
