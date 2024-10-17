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
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ProjeXpertWeb do
    pipe_through :browser

    get "/", PageController, :home
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
      live "/admins/register", UserRegistrationLive, :admin
      live "/client/register", UserRegistrationLive, :client
      live "/worker/register", UserRegistrationLive, :worker
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
      on_mount: [{ProjeXpertWeb.UserAuth, :ensure_authenticated}, ProjeXpertWeb.Nav] do
      live "/dashboard", DashboardLive.Index, :index
      live "/tasks", TasksLive.Index, :index
      live "/tasks/new", TasksLive.Index, :new
      live "/tasks/bids/new", TasksLive.Index, :new_bid
      live "/tasks/:id/show", TasksLive.Show, :show
      live "/bids", BidsLive.Index, :index
      live "/bids/:id/edit", BidsLive.Index, :edit
      live "/projects", ProjectsLive.Index, :index
      live "/projects/new", ProjectsLive.Index, :new
      live "/projects/:id/edit", ProjectsLive.Index, :edit
      live "/projects/:id/show", ProjectsLive.Show, :show
      live "/projects/:id/new_column", ProjectsLive.Show, :new_column
      live "/projects/:id/new_task", ProjectsLive.Show, :projects_new_task
      live "/projects/:id/edit_task/:task_id", ProjectsLive.Show, :projects_edit_task
      live "/projects/:id/show_task/:task_id", ProjectsLive.Show, :projects_show_task
      live "/projects/:id/edit_column/:column_id", ProjectsLive.Show, :edit_column
      live "/projects/show/:id/edit", ProjectsLive.Show, :edit
      live "/settings", UserSettingsLive, :edit
      live "/settings/confirm_email/:token", UserSettingsLive, :confirm_email
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
end
