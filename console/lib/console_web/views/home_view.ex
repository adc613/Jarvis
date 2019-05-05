defmodule ConsoleWeb.HomeView do
  use ConsoleWeb, :view

  def render("test.json", %{test: user}) do
    %{test: "foo"}
  end
end
