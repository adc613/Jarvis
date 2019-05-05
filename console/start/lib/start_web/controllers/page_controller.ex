defmodule StartWeb.PageController do
  use StartWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
