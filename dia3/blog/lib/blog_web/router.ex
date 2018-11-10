defmodule BlogWeb.Router do
  use BlogWeb, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true     
  end

  # Add this block
  scope "/" do
    pipe_through :browser
    coherence_routes()
  end

   # Add this block
   scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/", BlogWeb do
    pipe_through :browser # Use the default browser stack   
    get "/", PageController, :index   
  end

  scope "/", BlogWeb do
    pipe_through :protected
    # Add protected routes below    
    resources "/posts", PostController
          
  end

  # Other scopes may use custom stacks.
  # scope "/api", BlogWeb do
  #   pipe_through :api
  # end
end
