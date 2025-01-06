defmodule ProjeXpertWeb.Router do
  use ProjeXpertWeb, :router

  import ProjeXpertWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ProjeXpertWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :put_user_token
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ProjeXpertWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/webhooks", ProjeXpertWeb do
    pipe_through :browser
    post "/stripe", WebhookController, :stripe
  end

  # Other scopes may use custom stacks.
  # scope "/api", ProjeXpertWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:proje_xpert, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ProjeXpertWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ProjeXpertWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ProjeXpertWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      scope "/register" do
        live "/admins", UserRegistrationLive, :admin
        live "/client", UserRegistrationLive, :client
        live "/freelancer", UserRegistrationLive, :freelancer
      end

      live "/log_in", UserLoginLive, :new
      live "/reset_password", UserForgotPasswordLive, :new
      live "/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/log_in", UserSessionController, :create

    scope "/auth" do
      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
  end

  scope "/", ProjeXpertWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [
        {ProjeXpertWeb.UserAuth, :ensure_authenticated},
        {ProjeXpertWeb.Path, :put_path_in_socket},
        ProjeXpertWeb.Nav,
        ProjeXpertWeb.NotificationMount
      ] do
      scope "/bids", BidsLive do
        live "/", Index, :index
        live "/:id/edit", Index, :edit
        live "/:id/show", Show, :show
      end

      scope "/channels", ChannelsLive do
        live "/", Index, :index
        live "/:id/edit", Index, :edit
        live "/:id/show", Show, :show
      end

      live "/dashboard", DashboardLive.Index, :index

      scope "/payments", PaymentsLive do
        live "/", Index, :index
        live "/new", Index, :new
        live "/:id/edit", Index, :edit
        # live "/:id/show", Show, :show
      end

      scope "/projects", ProjectsLive do
        live "/", Index, :index
        live "/new", Index, :new
        live "/:id/edit", Index, :edit
        live "/:id/show", Show, :show
        live "/:id/new_column", Show, :new_column
        live "/:id/new_task", Show, :new_task
        live "/:id/new_sprint", Show, :new_sprint
        live "/:id/tasks/:task_id/edit", Show, :edit_task
        live "/:id/tasks/:task_id/show", Show, :show_task
        live "/:id/column/:column_id/edit", Show, :edit_column
        live "/:id/sprints/:sprint_id/edit", Show, :edit_sprint
        live "/show/:id/edit", Show, :edit
        live "/:id/channels/new", Show, :new_channel
      end

      scope "/tasks", TasksLive do
        live "/", Index, :index
        live "/new", Index, :new
        live "/bids/new", Index, :new_bid
        live "/:id/show", Show, :show
      end

      scope "/settings", SettingsLive do
        live "/", Index, :edit
        live "/email/:token/confirm", Index, :confirm_email
        live "/new_pm", Index, :new_pm
      end
    end
  end

  scope "/", ProjeXpertWeb do
    pipe_through [:browser]

    delete "/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ProjeXpertWeb.UserAuth, :mount_current_user}] do
      live "/confirm/:token", UserConfirmationLive, :edit
      live "/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, System.get_env("PROJECT_SECRET_KEY"), current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end
end
