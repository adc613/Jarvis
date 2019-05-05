defmodule ConsoleWeb.HomeController do
  use ConsoleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def doorbell(conn, _params) do 
    conn
      |> put_status(:ok) 
      |> render(ConsoleWeb.HomeView, "test.json", test: 3)
  end
end
