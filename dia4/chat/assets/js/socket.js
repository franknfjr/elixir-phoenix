// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import { Socket, Presence } from "phoenix";

let socket = new Socket("/socket", { params: { token: window.userToken } });

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect();

let presences = {};

let channelRoomId = window.channelRoomId;
if (channelRoomId) {
  // Now that you are connected, you can join channels with a topic:
  let channel = socket.channel(`room:${channelRoomId}`, {});
  channel
    .join()
    .receive("ok", resp => {
      console.log("Joined successfully", resp);
    })
    .receive("error", resp => {
      console.log("Unable to join", resp);
    });

  channel.on(`room:${channelRoomId}:new_message`, message => {
    console.log("message", message);
    renderMessage(message);
  });

  channel.on("presence_state", state => {
    presences = Presence.syncState(presences, state)
    renderOnlineUsers(presences)
  })
  
  channel.on("presence_diff", diff => {
    presences = Presence.syncDiff(presences, diff)
    renderOnlineUsers(presences)
  })

  document.querySelector("#new-message").addEventListener("submit", e => {
    e.preventDefault();
    let messageInput = e.target.querySelector("#message-content");
    channel.push("message:add", { message: messageInput.value });
    messageInput.value = "";
  });
}
const renderMessage = (message) => {
  let messageTemplate = `
    <li class="list-group-item">
      <strong>${message.user.username}</strong>:
      ${message.content}
    </li>
  `;
  document.querySelector("#messages").innerHTML += messageTemplate;
};

const renderOnlineUsers = (presences) => {
  let onlineUsers = Presence.list(presences, (_id, {metas: [user]}) => {
    return onlineUserTemplate(user);
  }).join("")

  document.querySelector("#online-users").innerHTML = onlineUsers;
}

const onlineUserTemplate = (user) => {
  return `
    <div id="online-user-${user.user_id}">
      <strong class="text-secondary">${user.username}</strong>
    </div>
  `
}

export default socket;
