defmodule TypoKartWeb.Router do
  use TypoKartWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug Phoenix.LiveView.Flash
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TypoKartWeb do
    pipe_through :browser

    get "/", PageController, :index
    live "/clock", ClockLive
    live "/race", RaceLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", TypoKartWeb do
  #   pipe_through :api
  # end
end
