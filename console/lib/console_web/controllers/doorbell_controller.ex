defmodule ConsoleWeb.DoorbellController do
  use ConsoleWeb, :controller

  def doorbell(conn, _params) do 
    conn
      |> put_status(:ok) 
      |> render(ConsoleWeb.HomeView, "test.json", test: 3)
  end
end
