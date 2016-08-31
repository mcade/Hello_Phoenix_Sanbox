defmodule HelloPhoenix.Router do
  use HelloPhoenix.Web, :router

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

  scope "/", HelloPhoenix do
    pipe_through [:browser, HelloPhoenix.SimpleAuth]

    get "/", PageController, :index
    resources "/reflections", ReflectionController
    resources "/session", SessionController, only: [:show]
    resources "/session", SessionController, only: [:delete], singleton: true
  end

  # Other scopes may use custom stacks.
  # scope "/api", HelloPhoenix do
  #   pipe_through :api
  # end
end
