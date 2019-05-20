defmodule ConsoleWeb.Router do
  use ConsoleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ConsoleWeb do
    pipe_through :browser

    get "/", DashboardController, :index
  end

  scope "/api", ConsoleWeb do
    pipe_through :api

    get "/doorbell", DoorbellController, :ring_doorbell
    get "/test", DoorbellController, :test
  end
end
