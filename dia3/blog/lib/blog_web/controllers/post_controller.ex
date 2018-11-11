defmodule BlogWeb.PostController do
  use BlogWeb, :controller
  
  alias Blog.Submit
  alias Blog.Submit.Post
  alias Blog.Coherence.User

  plug PolicyWonk.LoadResource, [:post] when action in [:show, :edit, :update, :delete]
  plug PolicyWonk.Enforce, :post_owner when action in [:show, :edit, :update, :delete]

  def index(conn, _params) do    
    posts = Submit.list_posts()
    render(conn, "index.html", posts: posts)
  end

  def new(conn, _params) do
    changeset = Submit.change_post(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Submit.create_post(conn.assigns.current_user,post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: post_path(conn, :show, post))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Submit.get_post!(id)
    render(conn, "show.html", post: post)
  end

  def edit(conn, %{"id" => id}) do
    post = Submit.get_post!(id)
    changeset = Submit.change_post(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Submit.get_post!(id)

    case Submit.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: post_path(conn, :show, post))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Submit.get_post!(id)
    {:ok, _post} = Submit.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: post_path(conn, :index))
  end

  def policy(assigns, :post_owner) do
    case {assigns[:current_user], assigns[:post]} do
      {%Blog.Coherence.User{id: user_id}, post=%Blog.Submit.Post{}} ->
        case post.user_id do
          ^user_id -> :ok
          _ -> :not_found
        end
      _ -> :not_found
    end
  end
  
  def policy_error(conn, :not_found) do
    BlogWeb.ErrorHandlers.resource_not_found(conn, :not_found)
  end
  
  def load_resource(_conn, :post, %{"id" => id}) do
    case Submit.get_post!(id) do
      nil -> :not_found
      post -> {:ok, :post, post}
    end
  end
    
end
