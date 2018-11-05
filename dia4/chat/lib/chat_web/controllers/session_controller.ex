defmodule ChatWeb.SessionController do
  use ChatWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end
end
