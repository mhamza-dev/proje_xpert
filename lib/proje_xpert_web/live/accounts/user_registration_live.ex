defmodule ProjeXpertWeb.UserRegistrationLive do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Accounts
  alias ProjeXpert.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register as <%= if @live_action == :worker, do: "Job Seeker", else: "Job Poster" %>
        <:subtitle>
          Already registered?
          <.link navigate={~p"/log_in"} class="font-semibold text-primary hover:underline">
            Log in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <div class="flex justify-center space-x-6">
          <.input field={@form[:first_name]} type="text" label="First Name" required />
          <.input field={@form[:last_name]} type="text" label="Last Name" required />
        </div>
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />
        <.input
          field={@form[:password_confirmation]}
          type="password"
          label="Confirm Password"
          required
        />
        <.input field={@form[:role]} type="hidden" value={@live_action} />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
        <div class="text-md text-right">
          Sign-up as
          <.link
            :if={@live_action == :worker}
            navigate={~p"/client/register"}
            class="font-semibold text-primary hover:underline"
          >
            Job Poster
          </.link>
          <.link
            :if={@live_action == :client}
            navigate={~p"/worker/register"}
            class="font-semibold text-primary hover:underline"
          >
            Job Seeker
          </.link>
        </div>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/confirm/#{&1}")
          )

        {:noreply,
         socket
         |> put_flash(:info, "We've sent you an email, Please verify your email")
         |> redirect(to: ~p"/log_in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
