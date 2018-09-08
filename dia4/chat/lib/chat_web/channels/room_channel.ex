defmodule ChatWeb.RoomChannel do
  use ChatWeb, :channel

  def join("room:lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("message:new", payload, socket) do
    broadcast! socket, "message:new", %{user: payload["user"], message: payload["message"]}
    {:noreply, socket}
  end
end
