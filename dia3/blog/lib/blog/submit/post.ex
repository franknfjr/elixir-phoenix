defmodule Blog.Submit.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Submit.Post

  schema "posts" do
    field :body, :string
    field :title, :string

    belongs_to :user,  Blog.Coherence.User
    timestamps()
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:title, :body, :user_id])
    |> validate_required([:title, :body])
  end
end
