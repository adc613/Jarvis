defmodule ConsoleWeb.DashboardController do
  use ConsoleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

