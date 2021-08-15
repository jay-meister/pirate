defmodule PirateWeb.Router do
  use PirateWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PirateWeb do
    pipe_through :api

    get "/", BookingController, :index
    get "/stats", BookingController, :stats
  end
end
