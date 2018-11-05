defmodule ChatWeb.Router do
  use ChatWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ChatWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", RoomController, :index)
    resources("/rooms", RoomController)

    resources("/sessions", SessionController, only: [:new, :create])
    delete("/sign_out", SessionController, :delete)

    resources("/registrations", RegistrationController, only: [:new, :create])
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChatWeb do
  #   pipe_through :api
  # end
end
