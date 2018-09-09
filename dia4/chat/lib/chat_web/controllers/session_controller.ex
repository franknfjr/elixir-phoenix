defmodule ChatWeb.SessionController do
  use ChatWeb, :controller
  alias Chat.Auth

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Auth.sign_in(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, "You have successfully signed in!")
        |> redirect to: "/"
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid E/PW")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Auth.sign_out()
    |> redirect to: "/sessions/new"
  end

end
