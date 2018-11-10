defmodule Chat.Conversation.Room do
  use Ecto.Schema
  import Ecto.Changeset
  alias Chat.Conversation.Room
  schema "rooms" do
    field(:desc, :string)
    field(:name, :string)
    field(:topic, :string)
    belongs_to(:user, Chat.Auth.User)
    timestamps()
  end

  @doc false
  def changeset(%Room{} = room, attrs) do
    room
    |> cast(attrs, [:name, :desc, :topic])
    |> validate_required([:name, :desc])
    |> unique_constraint(:name)
    |> validate_length(:name, min: 3, max: 25)
    |> validate_length(:topic, min: 5, max: 100)
  end
end
