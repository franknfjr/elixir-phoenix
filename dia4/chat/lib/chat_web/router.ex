defmodule ChatWeb.Router do
  use ChatWeb, :router
  import Plug.Conn

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:put_user_token)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ChatWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index, as: :page_path)

    resources("/sessions", SessionController, only: [:new, :create])
    delete("/sign_out", SessionController, :delete)

    resources("/registrations", RegistrationController, only: [:new, :create])
  end

  defp put_user_token(conn, _) do
    current_user = Plug.Conn.get_session(conn, :current_user_id)
    user_id_token = Phoenix.Token.sign(conn, "user_id", current_user)

    conn
    |> assign(:user_id, user_id_token)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChatWeb do
  #   pipe_through :api
  # end
end
