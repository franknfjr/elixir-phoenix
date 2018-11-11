defmodule BlogWeb.ErrorHandlers do
  use BlogWeb, :controller
  import BlogWeb.Router.Helpers

  def unauthorized(conn, error_str \\ nil ) do
    conn
    |> put_flash(:error, error_str || "Unauthorized")
    |> redirect(to: session_path(conn, :new))
    |> halt()
  end

  def resource_not_found(conn, _error_str \\ nil) do
    conn
      |> put_status(404)
      |> put_view(BlogWeb.ErrorView)
      |> render("404.html")
      |> halt()
  end

end
