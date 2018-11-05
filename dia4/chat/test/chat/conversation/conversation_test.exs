defmodule Chat.ConversationTest do
  use Chat.DataCase

  alias Chat.Conversation

  describe "rooms" do
    alias Chat.Conversation.Room

    @valid_attrs %{desc: "some desc", name: "some name", topic: "some topic"}
    @update_attrs %{desc: "some updated desc", name: "some updated name", topic: "some updated topic"}
    @invalid_attrs %{desc: nil, name: nil, topic: nil}

    def room_fixture(attrs \\ %{}) do
      {:ok, room} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Conversation.create_room()

      room
    end

    test "list_rooms/0 returns all rooms" do
      room = room_fixture()
      assert Conversation.list_rooms() == [room]
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert Conversation.get_room!(room.id) == room
    end

    test "create_room/1 with valid data creates a room" do
      assert {:ok, %Room{} = room} = Conversation.create_room(@valid_attrs)
      assert room.desc == "some desc"
      assert room.name == "some name"
      assert room.topic == "some topic"
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Conversation.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture()
      assert {:ok, room} = Conversation.update_room(room, @update_attrs)
      assert %Room{} = room
      assert room.desc == "some updated desc"
      assert room.name == "some updated name"
      assert room.topic == "some updated topic"
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = room_fixture()
      assert {:error, %Ecto.Changeset{}} = Conversation.update_room(room, @invalid_attrs)
      assert room == Conversation.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = Conversation.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Conversation.get_room!(room.id) end
    end

    test "change_room/1 returns a room changeset" do
      room = room_fixture()
      assert %Ecto.Changeset{} = Conversation.change_room(room)
    end
  end
end
