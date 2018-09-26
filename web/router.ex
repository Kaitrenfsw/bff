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
    post "/users", AdminController, :create_account
    post "/processing/model", ProcessingController, :update_model
    get "/users", AdminController, :index
    get "/users/:id", AdminController, :show
    delete "/users", AdminController, :delete_account
    put "/users", AdminController, :update_account
    get "/profile", UserController, :show
    put "/profile", UserController, :update
    get "/topics", TopicController, :index
    get "/topics/:id", TopicController, :show
    get "/topicUser/:id", UserController, :topics
    put "/topicUser/:id", UserController, :update_topics
    put "/account/activate", AdminController, :lock_account
  end
end
