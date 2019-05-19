defmodule ConsoleWeb.DoorbellView do
  use ConsoleWeb, :view

  def render("test.json", %{test: user}) do
    %{test: "foo"}
  end
end

