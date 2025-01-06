defmodule ProjeXpertWeb.WebhookController do
  use ProjeXpertWeb, :controller

  def stripe(conn, params) do
    update_payment(params["data"]["object"])
    conn
  end

  def update_payment(%{"status" => status, "metadata" => %{"payment_id" => p_id}}) do
    send(self(), {:update_payment,p_id, status})
  end

  def return() do
    %{
      "api_version" => "2024-10-28.acacia",
      "created" => 1_733_571_863,
      "data" => %{
        "object" => %{
          "canceled_at" => nil,
          "shipping" => nil,
          "livemode" => false,
          "customer" => "cus_RM4SqMZqpuHloQ",
          "statement_descriptor" => nil,
          "amount_capturable" => 0,
          "capture_method" => "automatic_async",
          "receipt_email" => "alice@example.com",
          "processing" => nil,
          "amount_details" => %{"tip" => %{}},
          "payment_method" => nil,
          "created" => 1_733_571_863,
          "transfer_data" => nil,
          "source" => nil,
          "application" => nil,
          "latest_charge" => nil,
          "statement_descriptor_suffix" => nil,
          "invoice" => nil,
          "status" => "requires_payment_method",
          "description" => nil,
          "id" => "pi_3QTMQtFGwcmeXAOP0K4cbNOA",
          "application_fee_amount" => nil,
          "payment_method_options" => %{
            "card" => %{
              "installments" => nil,
              "mandate_options" => nil,
              "network" => nil,
              "request_three_d_secure" => "automatic"
            },
            "link" => %{"persistent_token" => nil}
          },
          "currency" => "usd",
          "object" => "payment_intent",
          "on_behalf_of" => nil,
          "cancellation_reason" => nil,
          "client_secret" => "pi_3QTMQtFGwcmeXAOP0K4cbNOA_secret_qcBnmzmk4ootiMkihu7GjIkzo",
          "payment_method_types" => ["card", "link"],
          "automatic_payment_methods" => %{"allow_redirects" => "never", "enabled" => true},
          "next_action" => nil,
          "transfer_group" => nil,
          "amount_received" => 0,
          "review" => nil,
          "amount" => 149_089,
          "metadata" => %{
            "payment_id" => "9672166b-bd81-4004-89d0-f788c7caaf4d",
            "task_id" => "7648c223-05e2-42ff-ae3a-a475572dfcb0"
          },
          "setup_future_usage" => nil,
          "last_payment_error" => nil,
          "payment_method_configuration_details" => %{
            "id" => "pmc_1QLJtkFGwcmeXAOPERoFYoet",
            "parent" => nil
          },
          "confirmation_method" => "automatic"
        }
      },
      "id" => "evt_3QTMQtFGwcmeXAOP0QVVqL2B",
      "livemode" => false,
      "object" => "event",
      "pending_webhooks" => 1,
      "request" => %{
        "id" => "req_N2BoRE4qKqqmey",
        "idempotency_key" => "55c5b7ae-e849-4b81-875f-17e7a0c99fa5"
      },
      "type" => "payment_intent.created"
    }
  end
end
