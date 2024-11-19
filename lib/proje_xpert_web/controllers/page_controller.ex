defmodule ProjeXpertWeb.PageController do
  use ProjeXpertWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, "home.html")
  end
end
