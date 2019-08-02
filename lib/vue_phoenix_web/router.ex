defmodule VuePhoenixWeb.Router do
  use VuePhoenixWeb, :router

  pipeline :authenticate do
    plug VuePhoenix.Plugs.Authenticate
  end

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

  scope "/", VuePhoenixWeb do
    pipe_through :browser
    get "/*path", PageController, :index
  end

  scope "/api", VuePhoenixWeb do
    post "/auth", SessionsController, :create
  end

  scope "/api", VuePhoenixWeb do
    pipe_through :authenticate
    delete "/auth", SessionsController, :delete
  end


  # Other scopes may use custom stacks.
  # scope "/api", VuePhoenixWeb do
  #   pipe_through :api
  # end
end
