# Introdução ao Phoenix Framework & Como funciona em ação

* O que é o Phoenix?
* Router
* Plug
* Endpoint
* Controllers
* Views
* Templates
* Channels
* Ecto
* Context
* Tarefas MIX

# O que é o Phoenix?

É um framework web escrito em Elixir, com padrão MVC do lado do servidor. Tem conceitos e componentes parecidos com outros frameworks web como o Ruby on Rails ou Django do Python. 

Uma das vantagens que o Phoenix proporciona é a alta produtividade do desenvolvedor e alto desempenho de aplicativos. Os canais para implementar recurso em tempo real e modelos pré-compilados que possibilitam uma velocidade incrível.

Nesse curso será tratado as partes que o compõem e as camadas adjacentes que o suportam. O mesmo é composto de varias partes distintas, cada um desses tem sua finalidade e parte a exercer na criação de uma aplicação web.

Falando sobre as camadas é importande resaltar que a Phoenix é a camada superior de um sistema multicamadas, projetado para ser modular e flexível. E as demais são Cowboy,Plug e Ecto.

## Cowboy

É o servidor web padrão usado pelo Phoenix. O mesmo é pequeno, rápido, modular e escrito em Erlang. Seu objetivo é forncer uma pilha HTTP completa, incluído seus derivados SPDY, Websoket e REST.

O Plug e Ecto serão abordatos mais a frente, com mais detalhes e exemplos.

## Router

O `Router` tem como principais funções corresponder ás solicitações HTTP para ações do `controller`, conectam os manipuladores do canal e define uma série de transformações de pipeline para o middleware de definição de escopo para conjuntos de rotas.

O arquivo gerado pelo Phoenix é `router.ex` e fica no diretório `lib/app_web/router.ex`, e será um arquivo parecido com esse:

```elixir

defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AppWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", AppWeb do
  #   pipe_through :api
  # end
end
```

No seu arquivo o nome dado ao seu aplicativo ficará no lugar de `App` isso vale para o módulo do `router` e `controller`. A primeira linha desse módulo `use AppWeb, :router`, torna as funções do router Phoenix disponível em nosso router específico. Lembre-se os pipelines permitem que um conjunto de transformações de middleware seja aplicado a diferentes conjuntos de rotas.

Se observar dentro do bloco de `scope` temos nossa primeira rota real:

```elixir

get "/", PageController, :index
```

`Get` é uma macro Phoenix que se extende para definir uma cláusula da função match/5. Corresponde ao verbo HTTP GET. Macros semelhantes existem para outros verbos HTTP, incluindo POST, PUT, PATCH, DELETE, OPÇÕES,CONNECT, TRACE e HEAD.

A macro acima tem como primeiro argumento `"/"`, esse é o caminho da raiz da aplicação. Os outros dois argumentos são o `controller` e a ação, que queremos manusear nessa solicitação.

**Averiguando Router**

O Phoenix tem uma ferramenta para analisar rotas em um aplicativo, através do comando `phx.routes`. Seu funcionamento basíco é da seguinte forma. Precisa ir na raiz do aplicativo e executar `mix phx.routes`.

Obs.: Caso não tenha feito isso, é preciso executar `mix do deps.get, compile` antes de executar a tarefa `routes`. Será visto um resultado parecido com esse:

```elixir

$ mix phx.routes
page_path  GET  /  AppWeb.PageController :index
```

A saída quer dizer que qualquer comunicação HTTP GET para a raiz do aplicativo será manipulado pela `index` ação do `AppWeb.PageController`. O `page_path` funciona como um ajudante de trajetória.

**Recursos**

Além das macros get, post e put, existe o `resoucer` que expande para oito claúsulas da função match/5. Para testar adcionamos no arquivo `router.ex` a seguinte linha `resources "/users", UserController`.

```elixir

scope "/", AppWeb do
  pipe_through :browser # Use the default browser stack

  get "/", PageController, :index
  resources "/users", UserController
end
```

Em seguida vonte para a raiz da aplicação e digite `mix phx.routes`, aparecerá algo como:

```elixir

user_path  GET     /users           AppWeb.UserController :index
user_path  GET     /users/:id/edit  AppWeb.UserController :edit
user_path  GET     /users/new       AppWeb.UserController :new
user_path  GET     /users/:id       AppWeb.UserController :show
user_path  POST    /users           AppWeb.UserController :create
user_path  PATCH   /users/:id       AppWeb.UserController :update
           PUT     /users/:id       AppWeb.UserController :update
user_path  DELETE  /users/:id       AppWeb.UserController :delete
```

Caso não queira todas as rotas pode selecionar as desejadas com a `:only` e `except`.

**Only**

```elixir
resources "/posts", PostController, only: [:index, :show]
```

Temos rotas somente para leitura. Ao fazer a analise de rota com o comando `phx.routes`, temos rotas para o indice e mostrar as ações definidas.

```elixir
post_path  GET     /posts      AppWeb.PostController :index
post_path  GET     /posts/:id  AppWeb.PostController :show
```

**except**

Caso fosse criar um recurso de comentários, e não quisesse fornecer a rota para excluir, a rota seria dessa forma:

```elixir
resoucer "/coments", ComentController, except: [:delete]
```

Ao rodar o comando `phx.routes` teriamos um resultado parecido com esse:

```elixir
comment_path  GET    /comments           AppWeb.CommentController :index
comment_path  GET    /comments/:id/edit  AppWeb.CommentController :edit
comment_path  GET    /comments/new       AppWeb.CommentController :new
comment_path  GET    /comments/:id       AppWeb.CommentController :show
comment_path  POST   /comments           AppWeb.CommentController :create
comment_path  PATCH  /comments/:id       AppWeb.CommentController :update
              PUT    /comments/:id       AppWeb.CommentController :update
```

Em rotas tem muitas outras ações que podem ser feitas como: Forward, Path Helpers, Nested Resources, Scoped Routes, Pipelines e Channel Routes. Caso queira saber mais sobre estes que citamos aqui consulte o guia no site oficial Phoenix. Iremos falar sobre o Channel routes.

**Rota do canal**

Ela tem como função básica corresponder aos pedidos por soquete e tópico para enviar ao canal correto. Canais são componentes Phoenix que tratam questões em tempo real, manipulam mensagens de entrada e saída transmitida por um soket para um determinado tópico. Mais a frente falaremos detalhadamente de canais, agora vamos ver como a rota do canal funciona.

Manipulador de soket é montado no `endpoint.ex`, localizado no diretório `lib/app_web/endpointex.`, o mesmo cuida dos retornos de chamada de autenticação e das rotas do canal.

```elixir
defmodule AppWeb.Endpoint do
  use Phoenix.Endpoint

  socket "/socket", HelloWeb.UserSocket
  ...
end
```

Agora precisa do arquivo `user_socket.ex` localizado em `lib/app_web/channels/user_socket.ex`, usaremos a macro `channel/3` para definir nossa rota de canal. As rotas corresponderão a um padrão de tópicos para um canal manipular eventos. Caso tiver um módulo de canal chamado `SalaChannel` e um tópico chamado `"salas:*"`, teríamos um código parecido com esse:

```elixir
defmodule AppWeb.UserSocket do
  use Phoenix.Socket

  channel "salas:*", AppWeb.SalaChannel
  ...
end
```

Os tópicos são identificadores de string, o formato usado acima, nos permite definir tópicos e subtópicos na mesma string "topic:subtopic" e o `*` é um curinga que permite corresponder em qualquer subtópico. Sendo assim `"salas:1"` e `"salas:10"` seria correspondida pela mesma rota.

A Phoenix abstrai a camada de transporte de soquete e inclui dois mecanismos de transporte: WebSockets e Long-Polling. Se quiséssemos ter certeza de que nosso canal é gerenciado por apenas um tipo de transporte, poderíamos especificar isso usando a opção `via`.

```elixir
channel "salas:*", AppWeb.SalaChannel, via: [Phoenix.Transports.WebSocket]
```

Um soquete pode manipular solicitação para vários canais.

```elixir
channel "salas:*", AppWeb.SalaChannel, via: [Phoenix.Transports.WebSocket]
channel "tranportes:*", AppWeb.TransporteChannel
```

Tem a possibilidade de montar varios manipuladores de soquete no endpoint.

```elixir
socket "/socket", AppWeb.UserSocket
socket "/admin-socket", AppWeb.AdminSocket
```

## Plug

É composto de módulos ou funções reutilizáveis para construir aplicações web, oferece procedimento discreto, como análise ou registro de cabeçalho de solicitação. Pode ser gravado para tratar quase tudo, desde a autenticação até o pré-processamento de parâmetros e até a renderização.

Phoenix extrai grande proveito do Plug em geral, principalmente o router e o Controller. A especificação Plug vem em dois tipos: plug de função e plug de módulo.

### Plug de função

Para uma função atuar como um plug, a mesma precisa aceitar uma conexão struct (`%Plug.Conn{}`) e opções. Retornando uma estrutura de conexão. Veja como seria.

```elixir
#exemplo do guia phoenix https://hexdocs.pm/phoenix/plug.html

def put_headers(conn, key_values) do
  Enum.reduce key_values, conn, fn {k, v}, conn ->
    Plug.Conn.put_resp_header(conn, to_string(k), v)
  end
end
```

Para usar um plug em um controlador fariamos da seguinte forma.

```elixir
defmodule AppWeb.MessageController do
  use AppWeb, :controller

  plug :put_headers, %{content_encoding: "gzip", cache_control: "max-age=3600"}
  plug :put_layout, "sala.html"

  ...
end
```

Para enxegarmos melhor a eficiência do Plug, imagine um cenário onde precisa ser verificado uma série de condições e redirecionar ou parar se uma condição falhar. Sem o Plug seria basicamente assim:

```elixir
defmodule AppWeb.MessageController do
  use AppWeb, :controller

  def show(conn, params) do
    case authenticate(conn) do
      {:ok, user} ->
        case find_message(params["id"]) do
          nil ->
            conn |> put_flash(:info, "A mesagem não foi encontrada") |> redirect(to: "/")
          message ->
            case authorize_message(conn, params["id"]) do
              :ok ->
                render conn, :show, page: find_message(params["id"])
              :error ->
                conn |> put_flash(:info, "Não tem permissão para acessar a página") |> redirect(to: "/")
            end
        end
      :error ->
        conn |> put_flash(:info, "Precisa está logado") |> redirect(to: "/")
    end
  end
end
```

Para produzir poucas etapas de autorização e autenticação, foi exigido aninhamentos e duplicações um pouco complicadas. Agora usaremos o Plug de função para fazer a mesma coisa.

```elixir
defmodule AppWeb.MessageController do
  use AppWeb, :controller

  plug :authenticate
  plug :fetch_message
  plug :authorize_message

  def show(conn, params) do
    render conn, :show, page: find_message(params["id"])
  end

  defp authenticate(conn, _) do
    case Authenticator.find_user(conn) do
      {:ok, user} ->
        assign(conn, :user, user)
      :error ->
        conn |> put_flash(:info, "Precisa está logado") |> redirect(to: "/") |> halt()
    end
  end

  defp fetch_message(conn, _) do
    case find_message(conn.params["id"]) do
      nil ->
        conn |> put_flash(:info, "A mesagem não foi encontrada") |> redirect(to: "/") |> halt()
      message ->
        assign(conn, :message, message)
    end
  end

  defp authorize_message(conn, _) do
    if Authorizer.can_access?(conn.assigns[:user], conn.assigns[:message]) do
      conn
    else
      conn |> put_flash(:info, "Não tem permissão para acessar a página") |> redirect(to: "/") |> halt()
    end
  end
end
```

Assim obtemos a mesma funcionalidade de uma maneira muito mais composta, clara e reutilizável.

### Plug de módulo

Esse nos permite definir uma transformação de conexão em um módulo. Para isso o módulo necessita implementar duas funções:

`init/1` que inicialia quaisquer argumentos ou opções a serem passados para call/2;
`call/2` que realiza a transformação da conexão. O mesmo é um plug de função.

Veremos um exemplo de plug de módulo, que coloque a `:locale` chave e o valor na atribuição de conexão para uso downstream em outros plus, ações do controlador e nossas visualizações.

```elixir
defmodule AppWeb.Plugs.Locale do
  import Plug.Conn

  @locales ["en", "fr", "de"]

  def init(default), do: default

  def call(%Plug.Conn{params: %{"locale" => loc}} = conn, _default) when loc in @locales do
    assign(conn, :locale, loc)
  end

  def call(conn, default), do: assign(conn, :locale, default)
end

defmodule AppWeb.Router do
  use AppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug AppWeb.Plugs.Locale, "en"
  end
  ...
```

Podemos adicionar este plug de módulo ao nosso pipeline de navegador via `plug AppWeb.Plugs.Locale, "en"`. No `init/1` retorno de chamada, passamos uma localidade padrão para usar se nenhum estiver presente nos parâmetros. Também usamos a correspondência de padrões para definir várias `call/2` cabeças de função para validar a localidade nos parâmetros e voltar para "en" se não houver correspondência.

## Ecto