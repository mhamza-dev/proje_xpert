defmodule ProjeXpert.Stripe.Checkout do
  alias Stripe.Checkout.Session

  def create_checkout() do
    Session.create()
  end
end
