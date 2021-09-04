defmodule SampleWeb.Router do
  use SampleWeb, :router

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

  scope "/", SampleWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/", PageController, :new
  end
end
