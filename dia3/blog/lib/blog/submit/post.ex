defmodule Blog.Submit.Post do
  use Ecto.Schema
  import Ecto.Changeset
 


  schema "posts" do
    field :body, :string
    field :title, :string
    belongs_to :user,  Blog.Coherence.User
    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(params, [:title, :body])
    |> validate_required([:title, :body])
  end
end
