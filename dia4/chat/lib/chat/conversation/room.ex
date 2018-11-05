defmodule Chat.Conversation.Room do
  use Ecto.Schema
  import Ecto.Changeset


  schema "rooms" do
    field :desc, :string
    field :name, :string
    field :topic, :string

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :desc, :topic])
    |> validate_required([:name, :desc, :topic])
  end
end
