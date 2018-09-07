defmodule Bff.Router do
  use Bff.Web, :router

  pipeline :api do
  	plug CORSPlug, origin: "*"
    plug :accepts, ["json"]
  end

  scope "/", Bff do
  	get "/", HomeController, :heartbeat
  end

  scope "/api", Bff do
    pipe_through :api

    get "/content", ProcessingController, :content
    post "/user_content", ProcessingController, :topic_user
    post "/login", UserController, :login
  end
end
