defmodule ChatWeb.RoomChannel do
  use ChatWeb, :channel
  alias Chat.Repo
  alias Chat.Auth.User

  def join("room:" <> room_id, _params, socket) do
    {:ok, %{channel: "room:#{room_id}"}, assign(socket, :room_id, room_id)}
  end

  def handle_in("message:add", %{"message" => content}, socket) do
    room_id = socket.assigns[:room_id]
    user = Repo.get(User, socket.assigns[:current_user_id])
    message = %{content: content, user: %{username: user.username}}
    broadcast!(socket, "room:#{room_id}:new_message", message)
    {:reply, :ok, socket}
  end
end
