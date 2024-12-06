defmodule ProjeXpertWeb.UserConfirmationLive do
  use ProjeXpertWeb, :live_view

  alias ProjeXpert.Accounts
  alias ProjeXpert.Accounts.User

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <div class="mx-auto max-w-3xl h-[calc(100vh-10vh)] overflow-y-scroll">
      <h1 class="text-3xl font-bold text-center my-8">Confirm Your Account</h1>
      <.form
        :let={f}
        for={@changeset}
        id="confirmation_form"
        phx-submit="confirm_account"
        phx-change="validate"
        class="space-y-4"
      >
        <.input type="hidden" field={f[:token]} value={@token} />
        <div class="flex justify-between space-x-4">
          <.input
            type="text"
            field={f[:username]}
            label="Username"
            placeholder="apex-dealer"
            class="sm:w-[10rem] md:w-[15rem] lg:w-[20rem]"
            required
          />
          <.input
            type="text"
            field={f[:location]}
            label="Location"
            placeholder="231, California"
            class="sm:w-[10rem] md:w-[15rem] lg:w-[20rem]"
            required
          />
        </div>
        <.text_editor field={f[:bio]} id="user-bio" label="Bio" />
        <div>
          <div
            :if={!Enum.empty?(@uploads.profile.entries)}
            class="flex flex-col items-center justify-between"
          >
            <.live_img_preview
              class="h-44 w-44 object-cover rounded-full border-2 border-blue-400"
              entry={List.first(@uploads.profile.entries)}
            />
          </div>
          <.upload_attachments label="Upload Photo" upload_field={@uploads.profile} class="mb-0" />
        </div>
        <div class="flex justify-between space-x-4">
          <.input
            type="date"
            field={f[:birthdate]}
            label="Birthdate"
            class="sm:w-[10rem] md:w-[15rem] lg:w-[20rem]"
          />
          <.input
            type="select"
            field={f[:gender]}
            label="Gender"
            class="sm:w-[10rem] md:w-[15rem] lg:w-[20rem]"
            prompt="Select Gender"
            options={[
              Male: :male,
              Female: :female,
              Other: :other,
              "Prefer not to say": :prefer_not_to_say
            ]}
          />
        </div>
        <div class="flex items-center">
          <.input type="checkbox" field={f[:terms]} required />
          <label for="terms" class="ml-2 block text-sm text-gray-900">
            I agree to the
            <.link navigate="#" class="text-blue-600 hover:text-blue-500">Terms and Conditions</.link>
          </label>
        </div>
        <.button type="submit" class="w-full">
          Confirm Account
        </.button>
      </.form>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    {:ok,
     socket
     |> assign(
       token: token,
       changeset: Accounts.change_user_registration(%User{})
     )
     |> allow_upload(:profile,
       max_entries: 1,
       accept: exts_for_profile(),
       max_file_size: 5_000_000
     )}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      %User{}
      |> Accounts.change_user_profile(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def handle_event("confirm_account", %{"user" => params}, socket) do
    params =
      if Enum.empty?(socket.assigns.uploads.profile.entries) do
        params
      else
        url = List.first(upload_files(socket, :profile))
        Map.put(params, "profile_image", url)
      end

    case Accounts.confirm_user(params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "User confirmed successfully.")
         |> redirect(to: ~p"/")}

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            {:noreply, redirect(socket, to: ~p"/")}

          %{} ->
            {:noreply,
             socket
             |> put_flash(:error, "User confirmation link is invalid or it has expired.")
             |> redirect(to: ~p"/log_in")}
        end
    end
  end
end
