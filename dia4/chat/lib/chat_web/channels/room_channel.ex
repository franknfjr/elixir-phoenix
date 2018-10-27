defmodule ChatWeb.RoomChannel do
  use ChatWeb, :channel
  alias Chat.Repo
  alias Chat.Auth.User

  def join("room:lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("message:new", payload, socket) do
    # user = Repo.get(User, socket.assigns.user_id)

    broadcast!(socket, "message:new", %{message: payload["message"]})
    {:noreply, socket}
  end
end
