defmodule PirateWeb.Router do
  use PirateWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PirateWeb do
    pipe_through :api
  end
end
