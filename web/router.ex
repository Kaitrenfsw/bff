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
    get "/suggestions", UserController, :get_suggestions
    get "/relevant_suggestions", UserController, :relevant_suggestions
    post "/idms", OwnerController, :create_account
    get "/idms", OwnerController, :index
    put "/idms", OwnerController, :update_account
    put "/idms/password", OwnerController, :update_password
    delete "/idms", OwnerController, :delete_account
    get "/visualizations/graph", VisualizationController, :get_graph
    get "/visualizations/frequency_curve", VisualizationController, :get_frequency_curve
    get "/visualizations/hot_topics", VisualizationController, :get_hot_topics
    get "/visualizations/multiple_frequency_curve", VisualizationController, :get_multiple_frequency_curve
    get "/idms/dashboard", IdmController, :get_dashboard
    put "/idms/dashboard", IdmController, :update_dashboard
    delete "/idms/dashboard", IdmController, :delete_dashboard
    get "/new_votes", VoteController, :new_votes
    get "/source_votes", VoteController, :source_votes
    get "/one_source_votes", VoteController, :one_source_votes
    put "/update_user_vote", VoteController, :update_user_vote
    get "/get_user_votes", VoteController, :get_user_votes
    delete "/remove_user_source", VoteController, :remove_user_source
    put "/user_source", VoteController, :user_source
    get "/get_source_user", VoteController, :get_source_user
    post "/create_content_user", VoteController, :create_content_user
    put "/remove_content_user", VoteController, :remove_content_user
    get "/saved_news", VoteController, :saved_news
    get "/get_sources", VoteController, :get_sources
    get "/idms_sources", VoteController, :get_topic_stats
    get "/idms_topics", VoteController, :get_idm_topics
    get "/idms_logs", OwnerController, :user_logs
  end
end
