defmodule ConsoleWeb.DoorbellView do
  use ConsoleWeb, :view

  def render("test.json", %{state: :on}), do: %{test: "on"}
  def render("test.json", %{state: :off}), do: %{test: "off"}
  def render("test.json", %{state: :error}), do: %{test: "error"}
  def render("test.json", %{state: state}), do: %{test: "uknown"}
  def render("test.json", state) do
    %{on: state.on, sat: state.sat, bri: state.bri, hue: state.hue}
  end
end

