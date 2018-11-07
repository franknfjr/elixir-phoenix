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

`init/1` que inicializa quaisquer argumentos ou opções a serem passados para call/2; 
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

## Endpoints

Tem como função tratar as solicitações até o ponto que o roteador assume, o mesmo envia solicitações para um determinado roteador. É o início e o fim do ciclo de vida da solicitação. 

A aplicação inicia o `AppWeb.Endpoint` como um processo supervisionado. O Endpoint é adicionado à árvore de supervisão `lib/app/aplication.ex`, cada solicitação inicia e termina seu ciclo de vida dentro do aplicativo em um nó de extermidade. O nó lida com o início do servidor Web e a transformação de solicitações por meio de vários plugues definidos antes de chamar o roteador.
```elixir
defmodule App.Application do
  use Application
  def start(_type, _args) do
    #...

    children = [
      supervisorAppWeb.Endpoint, []),
    ]

    opts = [strategy: :one_for_one, name: App.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

### Conteúdo do Endpoint

Os pontos de extremidade reúnem funcionalidades comuns e servem como entrada e saída para todas as solicitações HTTP para seu aplicativo.

Iremos verificar o Endpoint da aplicação que será desenvolvida no último dia do curso.

```elixir
defmodule ChatWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :chat

  socket "/socket", ChatWeb.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :chat, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_chat_key",
    signing_salt: "ydEpUkQF"

  plug ChatWeb.Router

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end
end
```

A primeira chamada dentro do nosso módulo Endpoint é `use Phoenix.Endpointmacro` com o `otp_app`. O `otp_app` é usado para a configuração. Isso define várias funções no módulo `ChatWeb.Endpoint`, incluindo a função `start_link` que é chamada na árvore de supervisão.

```elixir
use Phoenix.Endpoint, otp_app: :chat
```

Depois, o nó de extremidade declara um soquete no URI "/soket". Sendo que as solicitações do soquete serão tratadas por `ChatWeb.UserSocket`, esse módulo se encontra em outro lugar na aplicação. Até esse momento foi declarado que a conexão existirá.

```elixir
socket "/socket", ChatWeb.UserSocket
```

Em seguida uma série de plugues que são relevantes para as solicitações da aplicação. Pode personalizar alguns dos recursos. Um deles é o `gzip`, se habilitar `gzip: true`, os arquivos estáticos seram compactados. Os arquivos estáticos são atendidos `priv/static` antes que qualquer parte de nossa solicitação chegue a um roteador.

```elixir
plug Plug.Static,
    at: "/", from: :chat, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)
```

Por padrão o recarregamento de código é ativo, o mesmo usa um soquete para comunicar ao navegador que a página precisa ser recarregada, quando o código for alterado no servidor.

```elixir
if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end
```

O `Plug.Logger`registra o caminho da solicitação, o código de atatus e a hora da solicitação.

O `Plug.Session` manipula os cookies de sessão e os armazenamentos de sessão.

```elixir
plug Plug.Session,
    store: :cookie,
    key: "_chat_key",
    signing_salt: "ydEpUkQF"
```

E o último plug é o roteador `plug ChatWeb.Router`, que corresponde a um caminho para uma determinada ação ou plug do controlador. O nó de extremidade pode ser personalizado para adicionar plugues, para permitir autenticação básica HTTP, CORS, roteamento de subdomínio e outras coisas mais.

Por fim a função `init` gerada por padrão no nó de extremidade. Usada para configuração dinâmica, retornando chamada.

```elixir

ef init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end
```

As falhas nas diferentes partes da árvore de supervisão, como o Ecto Repo, não afetarão imediatamente a aplicação principal. O supervisor é, portanto, capaz de reiniciar esses processos separadamente após falhas inesperadas. Também é possível que um aplicativo tenha vários pontos de extremidade, cada um com sua própria árvore de supervisão.

## Controllers

Atuam como módulos intermediários. Suas funções, denominadas como ações, são chamadas do roteador em resposta a solicitação HTTP. As mesmas reúnem todos os dados necessários e executam todas as etapas necessárias antes de invocar a camada de visualização para renderizar ou retornar uma resposta JSON.

Ao gerar um aplicativo Phoenix, o mesmo terá um único controlador, localiza em `lib/app_web/controller/page_controller.ex`.

```elixir
defmodule AppWeb.PageController do
  use AppWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
```

A primeira linha abaixo da definição do módulo chama a `__using__/1` macro do AppWeb módulo, que importa alguns módulos úteis.

O `PageController` nos dá a ação index, para exibir a página de boas-vindas do Phoenix associado com a rota padrão definida no roteador.

Existem convenções para nomes de ação que é recomendado seguir sempre que possível, embora possa criar qualquer nome para uma ação.

* index - renderiza uma lista de todos os itens do tipo de recurso fornecido;
* show - renderiza um item individual por id;
* novo - processa um formulário para criar um novo item;
* criar - recebe parâmetros para um novo item e os salva em um armazenamento de dados;
* edit - recupera um item individual por id e o exibe em um formulário para edição;
* update - recebe parâmetros para um item editado e salva em um armazenamento de dados;
* delete - recebe um id para um item a ser excluído e o exclui de um armazenamento de dados;

Observe no código acima que a ação usa dois `conn`e `params` parametros, que são fornecidos pela Phoenix nos bastidores.

O primeiro é sempre o **conn**, ele trás informações sobre o pedido, como o host, elementos de caminho, porta, cadeia de consulta e outras.

O segundo **params**, é um mapa que compõe todos os parâmetros transmitidos na solicitação HTTP. É uma boa prática padronizar a correspondência com parâmetros na assinatura da função para fornecer dados em um pacote simples que podemos transmitir para renderização. Exemplo ao adicionar um parâmetro de mensagem em nossa `show` rota `lib/app_web/controllers/app_controller.ex`. 

```elixir
defmodule AppWeb.AppController do
  . . .

  def show(conn, %{"messenger" => messenger}) do
    render conn, "show.html", messenger: messenger
  end
end
```

Tem casos de ações que precisa se importar com parâmetros, pois o comportamento não depende deles. Como pode ser observado na `index`, simplesmente o parâmetro foi prefixado com um sublinhado. Isso faz com que o compilador não se queixe da variável não utilizada, mantendo a aridade correta.

### Mensagens Flash

Tem momentos que aplicação precisa se comunicar com os usuários durante o percurso de uma ação. Para isso no módulo `Phoenix.Controller` temos duas funções a `put_flash/3` e `get_flash/2`, elas ajudam a definir e recuperar mensagens flash no nosso `AppWeb.PageController`. Segue um exemplo de como nossa `index` ficaria.

```elixir
defmodule AppWeb.PageController do
  . . .
  def index(conn, _params) do
    conn
    |> put_flash(:info, "Bem-vindo ao Phoenix, da informação de flash!")
    |> put_flash(:error, "Vamos fingir que temos um erro.")
    |> render("index.html")
  end
end
```

Para ver as mensagens flash, tem que recuperá-las e exibi-las em um template. Uma maneira de fazer a primeira parte é com o `get_flash/2` que toma `conn` e a chave com que nos importamos. Em seguida, retorna o valor para essa chave.

Mas o nosso layout de aplicativo `lib/app_web/templates/layout/app.html.eex`, já possui marcação para exibir mensagens flash.

```elixir
<p class="alert alert-info" role="alert"><%= get_flash(@conn, :info) %></p>
<p class="alert alert-danger" role="alert"><%= get_flash(@conn, :error) %></p>
```

Além das funções acima, o `Phoenix.Controller` módulo tem outra função útil, a `clear_flash/1` leva apenas `conn` e remove quaisquer mensagens flash que possam ser armazenadas na sessão.

### Renderização

A forma mais simples de renderizar algum texto é a função `text/2` que o Phoenix fornece.

Enunciamos que temos uma ação `show` que rece um id do mapa `params`, e precisamos retornar um texto qualquer com o id.

```elixir
def show(conn, %{"id" => id}) do
  text conn, "O id é #{id}"
end
```

Imagine uma rota mapear essa ação `get "/id_e/:id"`, ao ir para o `/id_e/20` seu navegador deve ser exibido `O id é 20` com texto simples sem qualquer HTML.

Podemo renderizar JSON puro também com a função `json/2`.

```elixir
def show(conn, %{"id" => id}) do
  json conn, %{id: id}
end
```

Ao visitar `/id_e/20` no navegador, será exibido um bloco JSON com a chave `id`.

```elixir
{"id": "20"}
```

Temos muito mais coisas sobre controller, caso queira aprender mais consulte o guia do phoenix framework.

## Views

As views do Phoenix tem dois principais trabalhos. A primeira é redenrizar arquivos que estão no templates. E também fornece funções que levam dados brutos e facilitam o consumo. `render/3` é a principal função que envolve a renderização.

### Modelos de renderização

A convenção de nomenclatura dos controladores para os modelos que eles renderizam é forte. O `PageControlller` requer um `PageView` para renderizar no diretório `lib/app_web/templates/page`. A raiz do template considerado pelo Phoenix, pode ser alterada. Ele oferece uma função `view/0` no módulo `AppWeb` localizado em `lib/app_web.ex`. A primeira linha da função `view/0` nos autoriza mudar o diretório raiz modificando o valor da chave `:root`.

```elixir
use Phoenix.View, root: "lib/chat_web/templates",
                        namespace: ChatWeb
```

Iremos verificar o `LayoutView`.

```elixir
defmodule ChatWeb.LayoutView do
  use ChatWeb, :view
end
```

Esse módulo tem apenas uma linha, que chama a função `view/0` a mesma exercita a macro `__using__` no `Phoenix.View`. Ela trata qualquer importação de módulo ou aliases. Que os módulos de visualização da aplicação possa necessitar.

Agora iremos abrir nosso modelo de layout de aplicativo `lib/app_web/templates/layout/app.html.exx` e alterar a seguinte linha.

```elixir
<title>Hello Hello!</title>
```

Vamos adcionar uma função `title/0` ao nosso `LayoutView`.

```elixir
defmodule AppWeb.LayoutView do
  use AppWeb, :view

  def title do
    "Um novo título!"
  end
end
```

Ao recarregar a página do Welcome to Phoenix, veremos nosso novo título.

Como a `view/0` função é importada `AppWeb.Router.Helpers`, não precisamos qualificar totalmente os auxiliares de caminho nos modelos. Vamos ver como isso funciona alterando o modelo para a nossa página Welcome to Phoenix.

Vamos abrir `lib/hello_web/templates/page/index.html.eexe` localizar essa parte do código.

```elixir
<div class="jumbotron">
  <h2><%= gettext "Welcome to %{name}!", name: "Phoenix" %></h2>
  <p class="lead">A productive web framework that<br>does not compromise speed and maintainability.</p>
</div>
```

Agora vamos adcionar um link que volta para a mesma página. Iremos ver como os auxiliares de caminho respodem em um modelo, sem precisar adicionar nenhuma funcionalidade.

```elixir
<div class="jumbotron">
  <h2><%= gettext "Welcome to %{name}!", name: "Phoenix" %></h2>
  <p class="lead">A productive web framework that<br>does not compromise speed and maintainability.</p>
  <p><a href="<%= page_path @conn, :index %>">Link back to this page</a></p>
</div>
```

Agora revifique o código fonte no seu navegador e veja o que temos.

Ótimo, `page_path/2` avaliado `/` como é de se esperar, e não precisávamos nos qualificar Phoenix.View.

## Renderização JSON

O trabalho da visão não é apenas renderizar modelos HTML. Visualizações são sobre apresentação de dados. Dado um pacote de dados, o objetivo da exibição é apresentar isso de maneira significativa, considerando algum formato, seja HTML, JSON, CSV ou outros.

É possível responder com JSON diretamente do controlador e pular a Visualização. No entanto, se pensarmos em um controlador como tendo as responsabilidades de receber uma solicitação e buscar dados a serem enviados de volta, a manipulação e a formatação de dados não se enquadram nessas responsabilidades. Uma visão nos dá um módulo responsável por formatar e manipular os dados. Vamos `PageController` ver o que pode parecer quando respondemos com alguns mapas de páginas estáticos como JSON, em vez de HTML.

```elixir
defmodule AppWeb.PageController do
  use AppWeb, :controller

  def show(conn, _params) do
    page = %{title: "JSON"}

    render conn, "show.json", page: page
  end

  def index(conn, _params) do
    pages = [%{title: "JSON"}, %{title: "DATA"}]

    render conn, "index.json", pages: pages
  end
end
```

Temos as ações `show/2` e `index/2` retornando dados de página estáticas. Em vez de passar `show.html` para `render/3` o nome do modelo, `show.json`. Dessa forma, podemos ter visões responsáveis ​​por renderizar HTML e JSON por correspondência de padrões em diferentes tipos de arquivos.

```elixir
defmodule AppWeb.PageView do
  use AppWeb, :view

  def render("index.json", %{pages: pages}) do
    %{data: render_many(pages, AppWeb.PageView, "page.json")}
  end

  def render("show.json", %{page: page}) do
    %{data: render_one(page, AppWeb.PageView, "page.json")}
  end

  def render("page.json", %{page: page}) do
    %{title: page.title}
  end
end
```

Na `View` o padrão de função  `render/2` correspondente em `index.json`, `show.json` e `page.json`. Em nossa função `show/2` de controlador, `render conn, "show.json", page: page` o padrão será igual ao nome e extensão correspondentes nas funçõa `render/2` da `View`. Em outras palavras, `render conn, "index.json", pages: pages` vai ligar `render("index.json", %{pages: pages})`. A função `render_many/3` pega os dados que queremos responder com `(pages)`, a `View` e uma string para correspondência de padrões na função `render/2` definida em `View`. Ele mapeará cada item `pages` e passará o item para a função `render/2` `View` correspondente à cadeia de arquivos. `render_one/3` Segue, a mesma assinatura, em última análise, usando a `render/2` correspondência `page.json` para especificar o que cada um `page` parece. A `render/2` correspondência `"index.json"` responderá com JSON como você esperaria:

```elixir
  {
    "data": [
      {
       "title": "JSON"
      },
      {
       "title": "DATA"
      },
   ]
  }
```

A função `render/2` correspondência `show.json`.

```elixir
  {
    "data": {
      "title": "JSON"
    }
  }
```

É útil construir nossos pontos de vista como este, para que possam ser compostos. Imagine uma situação em que o nosso relacionamento `Page` esteja `has_many` relacionado e `Author`, dependendo da solicitação, possamos enviar dados `author` com o `page`. Podemos facilmente conseguir isso com um novo `render/2`:

```elixir
defmodule AppWeb.PageView do
  use AppWeb, :view
  alias AppWeb.AuthorView

  def render("page_with_authors.json", %{page: page}) do
    %{title: page.title,
      authors: render_many(page.authors, AuthorView, "author.json")}
  end

  def render("page.json", %{page: page}) do
    %{title: page.title}
  end
end
```

O nome usado nas atribuições é determinado a partir da exibição. Por exemplo, o `PageView` vai usar `%{page: page}` e o `AuthorView` o `%{author: author}`. Isso pode ser substituído com a `as` opção. Vamos supor que a visualização do autor seja usada em `%{writer: writer}` em vez de `%{author: author}`:

```elixir
  def render("page_with_authors.json", %{page: page}) do
    %{title: page.title,
      authors: render_many(page.authors, AuthorView, "author.json", as: :writer)}
  end
```

## Templates

São arquivos onde passamos dados para formar resposta HTTP completas. Em uma plicação Web, essas seriam documetno HTML completos. Para api's "JSON" ou "XML". No Phoenix os `templates` são pré-compilados, fato que os torna muito rápidos.

EEx é o sistema de template padrão em Phoenix, e é bastante similar ao ERB em Ruby. Na verdade, é parte do próprio Elixir, e o Phoenix usa modelos EEx para criar arquivos como o roteador e a visualização principal do aplicativo ao gerar um novo aplicativo.

Eles estão localizados no diretório `lib/app_web/templates`, cada uma possui seu próprio módulo na `View` para renderizar os modelo nele.

**Exemplos**

Vamos definir uma outra rota para exercitar um pouco. Vá em `lib/app_web/router.ex`. E crie uma rota teste.

```elixir
get "/teste", PageController, :teste
```

Vamos iniciar nossa aplicação `mix phx.server` e acessar nossa nova rota.

Agora, vamos definir a ação do controlador que especificamos na rota. Nós vamos adicionar uma `test/2` ação no `lib/hello_web/controllers/page_controller.ex` arquivo.

```elixir
defmodule AppWeb.PageController do
  ...

  def test(conn, _params) do
    render conn, "test.html"
  end
end
```

Vamos criar uma função que nos informe qual controladora e ação estão manipulando nossa solicitação.

Para fazer isso, precisamos importar as funções `action_name/1e controller_module/1` de `Phoenix.Controllerdentro lib/app_web.ex`.

```elixir
  def view do
    quote do
      use Phoenix.View, root: "lib/hello_web/templates",
                        namespace: HelloWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1,
                                        action_name: 1, controller_module: 1]

      ...
    end
  end
```

Em seguida, vamos definir uma função `handler_info/1`  na parte inferior da `lib/hello_web/views/page_view.ex` qual faz uso das funções `controller_module/1` e `action_name/1` apenas importadas. Também vamos definir uma `connection_keys/1` função que usaremos em um momento.

```elixir
defmodule AppWeb.PageView do
  use AppWeb, :view

  def handler_info(conn) do
    "Request Handled By: #{controller_module conn}.#{action_name conn}"
  end

  def connection_keys(conn) do
    conn
    |> Map.from_struct()
    |> Map.keys()
  end
end
```

Nós temos uma rota. Criamos uma nova ação de controlador. Nós fizemos modificações na visualização principal do aplicativo. Agora tudo o que precisamos é de um novo modelo para exibir a string da qual obtemos `handler_info/1`. Vamos criar um novo em `lib/hello_web/templates/page/test.html.eex`.

```elixir
<div class="jumbotron">
  <p><%= handler_info @conn %></p>
</div>
```
Observe que `@conn` está disponível para nós no modelo através do `assigns` mapa.

Agora vamos testar acesse `localhost:4000/teste`, veremos que nossa página é trazida para nós por `Elixir.HelloWeb.PageController.test`.

Podemos definir funções em qualquer visão individual em `lib/hello_web/views`. As funções definidas em uma visão individual só estarão disponíveis para modelos que essa visão renderiza. Por exemplo, funções como as `handler_info` acima, só estarão disponíveis para modelos em `lib/hello_web/templates/page`.

Até agora, exibimos apenas valores singulares em nossos modelos - strings aqui e inteiros em outros guias. Como nos aproximaríamos de exibir todos os elementos de uma lista?

A resposta é que podemos usar as compreensões da lista do Elixir.

Agora que temos uma função, visível para o nosso template, que retorna uma lista de chaves na `connstruct`, tudo o que precisamos fazer é modificar `lib/hello_web/templates/page/test.html.eex` um pouco o nosso template para exibi-las.

Podemos adicionar um cabeçalho e uma compreensão de lista como essa.

```elixir
<div class="jumbotron">
  <p><%= handler_info @conn %></p>

  <h3>Keys for the conn Struct</h3>

  <%= for key <- connection_keys @conn do %>
    <p><%= key %></p>
  <% end %>
</div>
```

Usamos a lista de chaves retornadas pela função `connection_keys` como a lista de origem para iterar. Observe que precisamos do ``<%==>` em ambos.  um para a linha superior da compreensão da lista e o outro para exibir a chave. Sem eles, nada seria realmente exibido.

Quando visitamos `localhost:4000/teste` novamente, vemos todas as teclas exibidas.

## Channels

Os canais são uma parte realmente do Phoenix que nos permite adicionar facilmente recursos em tempo real aos nossos aplicativos. Os canais são baseados em uma ideia simples, enviar e receber mensagens. Remetentes transmitem mensagens sobre tópicos. Os receptores inscrevem-se em tópicos para que possam receber essas mensagens. Remetentes e destinatários podem alternar funções no mesmo tópico a qualquer momento.

A palavra "Canal" é uma forma abreviada de um sistema em camadas com vários componentes. Vamos dar uma rápida olhada neles agora para que possamos ver o quadro geral um pouco melhor.

A Phoenix vem com um cliente JavaScript que está disponível ao gerar um novo projeto Phoenix. A documentação do módulo JavaScript está disponível em https://hexdocs.pm/phoenix/js/

**Visão Geral**

O que é necessário para a comunicação acontecer?

* Se conectar a um soquete, usando um transporte (Websockets ou long polling);

O Websocket une um ou mais canais unsando uma única conexão de rede. Um processo de servidor de canal é criado por cliente e por tópico. O manipulador de soquete apropriado inicializa um `%Phoenix.Socket` para o servidor do canal (possivelmente após a autenticação do cliente). O servidor do canal, em seguida, segure o `%Phoenix.Socket{}` e pode manter qualquer estado que ele precisa dentro dele `socket.assigns`.

Depois que a conexão é estabelecida, as mensagens recebidas de um cliente são roteadas para o servidor de canais correto. Se transmite uma mensagem, essa mensagem vai primeiro para o PubSub local, que a envia para qualquer cliente conectado ao mesmo servidor e inscrito nesse tópico. O PubSub local também encaminha a mensagem para PubSubs remotos nos outros nós do cluster, que os enviam para seus próprios assinantes.

**Manipuladores de Soquetes**

É mantida uma conexão única para cada cliente e multiplexa seus soquetes de canal por essa única conexão. Os manipuladores de soquete, como `lib/hello_web/channels/user_socket.ex`, são módulos que autenticam e identificam uma conexão de soquete e permitem que você defina atribuições de soquete padrão para uso em todos os canais.

**Rotas do Canal**

As rotas são definidas nos manipularodes de soquete, Eles correspondem na sequência de tópicos e despacham solicitações correspondentes para o módulo do Canal. O caractere de estrela `*` atua como um correspondente de caractere curinga, portanto, na rota de exemplo a seguir, os pedidos `sample_topic:phoenix` e `sample_topic:elixir` os dois serão despachados para o SampleTopicChannel.

```elixir
channel "sample_topic:*", AppWeb.SampleTopicChannel
```

**Canais**

Os canais são a abstração de nível mais alto para componentes de comunicação em tempo real em Phoenix.

São semelhantes ao controladores, os mesmos manipulam eventos dos cliente. Os eventos do canal podem ir  em ambas as direções, entrada e saída. As conexões de canal também persistem além de um único ciclo de solicitação/resposta.

Cada canal irá implementar uma ou mais cláusulas de cada uma destas quatro funções de retorno de chamada `join/3`, `terminate/2`, `handle_in/3`, e `handle_out/3`.

**PubSub**

Consiste no módulo `Phoenix.PubSub` e uma variedade de módulos para diferentes adaptadores e seus `GenServer`. Esses módulos contêm funções que são as porcas e parafusos da organização da comunicação do Canal, assinando tópicos, cancelando a inscrição de tópicos e transmitindo mensagens sobre um tópico.

**Mensagens**

O módulo `Phoenix.Socket.Message` define uma estrutura com as seguintes chaves, que denota uma mensagem válida. Dos documentos `Phoenix.Socket.Message`.

`topic` - O tópico ou tópico de string: namespace de par de subtópicos, por exemplo, "mensagens", "mensagens: 123";

`event` - O nome do evento da string, por exemplo, "phx_join";

`payload` - A carga útil da mensagem;

`ref` - A referência única da string;

**Tópicos**

Os tópicos são identificadores de string - nomes que as várias camadas usam para garantir que as mensagens sejam colocadas no lugar certo. Como vimos acima, os tópicos podem usar curingas. Isso permite uma convenção “topic: subtopic” útil. Geralmente, você compõe tópicos usando IDs de registro da sua camada de aplicativo, como "users:123".

**Transportes**

A camada de transporte é onde a pneu encontra a estrada. O módulo `Phoenix.Channel.Transport` manipula toda a mensagem que entra e sai de um canal.

**Adaptadores de transporte**

O mecanismo de transporte padrão é via WebSockets, que retornará ao LongPolling se WebSockets não estiverem disponíveis. Outros adaptadores de transporte são possíveis, e podemos escrever nossos próprios se seguirmos o contrato do adaptador. Por favor, veja `Phoenix.TransportsWebSocket` um exemplo.

## Ecto

Ecto é um projeto oficial do Elixir que fornece uma camada de banco de dados e linguagem integrada para consultas. Com Ecto podemos criar migrations, definir schemas, inserir e atualizar registos, e fazer consultas.

## Instalação

Crie um novo app com uma supervision tree:

```shell
$ mix new example_app --sup
$ cd example_app
```

Para começar precisamos incluir Ecto e um adaptador de banco de dados no `mix.exs` do nosso projeto. Você pode encontrar uma lista de adaptadores de banco de dados suportados na seção [*Usage*](https://github.com/elixir-lang/ecto/blob/master/README.md#usage) do README do Ecto. Para o nosso exemplo iremos usar o PostgreSQL:

```elixir
defp deps do
  [{:ecto, "~> 2.2"}, {:postgrex, ">= 0.0.0"}]
end
```

Então nós vamos baixar nossas dependências usando

```shell
$ mix deps.get
```

### Repositório

Finalmente precisamos criar o repositório do nosso projeto, a camada de banco de dados. Isto pode ser feito rodando a tarefa `mix ecto.gen.repo -r ExampleApp.Repo`, falaremos sobre tarefas mix no Ecto mais para frente. O Repositório pode ser encontrado no arquivo `lib/<nome_do_projecto>/repo.ex`:

```elixir
defmodule ExampleApp.Repo do
  use Ecto.Repo, otp_app: :example_app
end
```

### Supervisor

Uma vez criado o nosso Repositório, precisamos configurar nossa árvore de supervisor, que normalmente é encontrada em `lib/<nome_do_projecto>.ex`. Adicione o Repo à lista `children`:

```elixir
defmodule ExampleApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      ExampleApp.Repo
    ]

    opts = [strategy: :one_for_one, name: ExampleApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

Para mais informações sobre supervisores, consulte a lição [Supervisores OTP](../../advanced/otp-supervisors).

### Configuração

Para configurar o Ecto precisamos adicionar uma seção no nosso `config/config.exs`. Aqui iremos especificar o repositório, o adaptador, o banco de dados e as informações de acesso ao banco de dados:

```elixir
config :example_app, ExampleApp.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "example_app",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
```

## Tarefas Mix

Ecto inclui uma série de tarefas mix úteis para trabalhar com o nosso banco de dados:

```shell
mix ecto.create         # Cria um banco de dados para o repositório
mix ecto.drop           # Elimina o banco de dados do repositório
mix ecto.gen.migration  # Gera uma nova *migration* para o repositório
mix ecto.gen.repo       # Gera um novo repositório
mix ecto.migrate        # Roda as migrations em cima do repositório
mix ecto.rollback       # Reverte migrations a partir de um repositório
```

## Migrations

A melhor forma de criar migrations é usando a tarefa `mix ecto.gen.migration <nome_da_migration>`. Se você está familiarizado com ActiveRecord, isto irá parecer familiar.

Vamos começar dando uma olhada numa migration para uma tabela *users*:

```elixir
defmodule ExampleApp.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:username, :string, unique: true)
      add(:encrypted_password, :string, null: false)
      add(:email, :string)
      add(:confirmed, :boolean, default: false)

      timestamps
    end

    create(unique_index(:users, [:username], name: :unique_usernames))
  end
end
```

Por padrão Ecto cria uma chave primária `id` auto incrementada. Aqui estamos usando o callback padrão `change/0` mas Ecto também suporta `up/0` e `down/0` no caso de precisar um controle mais granular.

Como você deve ter adivinhado, adicionando `timestamps` na sua migration irá criar e gerir os campos `inserted_at` e `updated_at` por você.

Para aplicar as alterações definidas na nossa migration, rode `mix ecto.migrate`.

Para mais informações dê uma olhada a seção [Ecto.Migration](http://hexdocs.pm/ecto/Ecto.Migration.html#content) da documentação.

## Schemas

Agora que temos nossa migration podemos continuar para o schema. Schema é um módulo, que define mapeamentos para uma tabela do banco de dados e seus campos, funções auxiliares, e nossos *changesets*. Iremos falar mais sobre *changesets* nas próximas seções.

Por agora vamos dar uma olhada em como o schema para nossa migration se parece:

```elixir
defmodule ExampleApp.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:username, :string)
    field(:encrypted_password, :string)
    field(:email, :string)
    field(:confirmed, :boolean, default: false)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)

    timestamps
  end

  @required_fields ~w(username encrypted_password email)
  @optional_fields ~w()

  def changeset(user, params \\ :empty) do
    user
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:username)
  end
end
```

O esquema que definimos representa de perto o que especificamos na nossa *migration*. Além dos campos para o nosso banco de dados, estamos também incluindo dois campos virtuais. Campos virtuais não são armazenados no banco de dados mas podem ser úteis em casos de validação. Veremos os campos virtuais em ação na seção [Changesets](#changesets).

## Consultas

Antes de poder consultar o nosso repositório, precisamos importar a *Query API*, mas por enquanto precisamos importar apenas `from/2`:

```elixir
import Ecto.Query, only: [from: 2]
```

A documentação oficial pode ser encontrada em [Ecto.Query](http://hexdocs.pm/ecto/Ecto.Query.html).

### O Básico

Ecto fornece uma excelente DSL<sup>(domain-specific language)</sup> de consulta que nos permite expressar consultas de forma muito clara. Para encontrar os usernames de todas as contas confirmadas poderíamos usar algo como este:

```elixir
alias ExampleApp.{Repo, User}

query =
  from(
    u in User,
    where: u.confirmed == true,
    select: u.username
  )

Repo.all(query)
```

Além do `all/2`, Repo fornece uma série de callbacks incluindo `one/2`, `get/3`, `insert/2`, e `delete/2`. Uma lista completa de callbacks pode ser encontrada em [Ecto.Repo#callbacks](http://hexdocs.pm/ecto/Ecto.Repo.html#callbacks).

### Count

Se nós queremos contar o números de usuários que tem uma conta confirmada, podemos usar `count/1`:

```elixir
query =
  from(
    u in User,
    where: u.confirmed == true,
    select: count(u.id)
  )
```

A função `count/2` também existe para contar os valores distintos de um dado entrada:

```elixir
query =
  from(
    u in User,
    where: u.confirmed == true,
    select: count(u.id, :distinct)
  )
```

### Group By

Para agrupar usernames por estado de confirmação podemos incluir a opção `group_by`:

```elixir
query =
  from(
    u in User,
    group_by: u.confirmed,
    select: [u.confirmed, count(u.id)]
  )

Repo.all(query)
```

### Order By

Ordenar usuários pela data de criação:

```elixir
query =
  from(
    u in User,
    order_by: u.inserted_at,
    select: [u.username, u.inserted_at]
  )

Repo.all(query)
```

Para ordenar por `DESC`:

```elixir
query =
  from(
    u in User,
    order_by: [desc: u.inserted_at],
    select: [u.username, u.inserted_at]
  )
```

### Joins

Assumindo que temos um perfil associado ao nosso usuário, vamos encontrar todos os perfis de contas confirmadas:

```elixir
query =
  from(
    p in Profile,
    join: u in assoc(p, :user),
    where: u.confirmed == true
  )
```

### Fragmentos

Às vezes a Query API não é suficiente, por exemplo, quando precisamos de funções específicas para banco de dados. A função `fragment/1` existe para esta finalidade:

```elixir
query =
  from(
    u in User,
    where: fragment("downcase(?)", u.username) == ^username,
    select: u
  )
```

Outros exemplos de consultas podem ser encontradas na descrição do módulo [Ecto.Query.API](http://hexdocs.pm/ecto/Ecto.Query.API.html).

## Changesets

Na seção anterior aprendemos como recuperar dados. Mas então como inserir e atualizá-los? Para isso precisamos de *Changesets*.

Changesets cuidam da filtragem, validação, manutenção das *constraints* quando alteramos um schema.

Para este exemplo iremos nos focar no *changeset* para criação de conta de usuário. Para começar precisamos atualizar o nosso schema:

```elixir
defmodule ExampleApp.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    field(:username, :string)
    field(:encrypted_password, :string)
    field(:email, :string)
    field(:confirmed, :boolean, default: false)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)

    timestamps
  end

  @required_fields ~w(username email password password_confirmation)
  @optional_fields ~w()

  def changeset(user, params \\ :empty) do
    user
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:password, min: 8)
    |> validate_password_confirmation()
    |> unique_constraint(:username, name: :email)
    |> put_change(:encrypted_password, hashpwsalt(params[:password]))
  end

  defp validate_password_confirmation(changeset) do
    case get_change(changeset, :password_confirmation) do
      nil ->
        password_incorrect_error(changeset)

      confirmation ->
        password = get_field(changeset, :password)
        if confirmation == password, do: changeset, else: password_mismatch_error(changeset)
    end
  end

  defp password_mismatch_error(changeset) do
    add_error(changeset, :password_confirmation, "Passwords does not match")
  end

  defp password_incorrect_error(changeset) do
    add_error(changeset, :password, "is not valid")
  end
end
```

Melhoramos nossa função `changeset/2` e adicionamos três novas funções auxiliares: `validate_password_confirmation/1`, `password_mismatch_error/1` e `password_incorrect_error/1`.

Como o próprio nome sugere, `changeset/2` cria para nós um novo *changeset*. Nele usamos `cast/3` para converter nossos parâmetros para um *changeset* a partir de um conjunto de campos obrigatórios e opcionais. Então nós validamos a presença dos campos obrigatórios. A seguir validamos o tamanho da senha do *changeset*, a correspondência da confirmação da senha usando a nossa propria função, e a unicidade do nome de usuário. Por último, atualizamos nosso campo `password` no banco de dados. Para tal usamos `put_change/3` para atualizar um valor no *changeset*.

Usar `User.changeset/2` é relativamente simples:

```elixir
alias ExampleApp.{User,Repo}

pw = "passwords should be hard"
changeset = User.changeset(%User{}, %{username: "doomspork",
                    email: "sean@seancallan.com",
                    password: pw,
                    password_confirmation: pw})

case Repo.insert(changeset) do
  {:ok, record}       -> # Inserted with success
  {:error, changeset} -> # Something went wrong
end
```

É isso aí! Agora você está pronto para guardar alguns dados.

## Context

Antes era com model... Hoje temos o context.

![alt Exemplo com model](https://cdn-images-1.medium.com/max/1200/1*9zM-5F5_RVAthQLbfQCABg.png)


![alt Exemplo com context](https://cdn-images-1.medium.com/max/1200/1*yif8KdMpf4yB9BFbTLfQVw.png)

Estrutura Context:
```shell
mix phx.gen.context Context Schema schemas
```

```shell
$ mix phx.gen.context CMS Author authors bio:text role:string 
genre:string user_id:references:users:unique

* creating lib/hello/cms/author.ex
* creating priv/repo/migrations/20170629200937_create_authors.exs
* injecting lib/hello/cms/cms.ex
* injecting test/hello/cms/cms_test.exs

Remember to update your repository by running migrations:

    $ mix ecto.migrate
```
## Tarefas MIX

É comum querer extender as funcionalidades da sua aplicação Elixir adicionando tarefas Mix customizadas. Antes de aprendermos como criar tarefas Mix específicas para nossos projetos, vamos dar uma olhada em uma já existente:

```shell
$ mix phoenix.new my_phoenix_app

* creating my_phoenix_app/config/config.exs
* creating my_phoenix_app/config/dev.exs
* creating my_phoenix_app/config/prod.exs
* creating my_phoenix_app/config/prod.secret.exs
* creating my_phoenix_app/config/test.exs
* creating my_phoenix_app/lib/my_phoenix_app.ex
* creating my_phoenix_app/lib/my_phoenix_app/endpoint.ex
* creating my_phoenix_app/test/views/error_view_test.exs
...
```

Como podemos ver no comando shell acima, o Framework Phoenix tem uma tarefa Mix customizada para criar um novo projeto. E se quiséssemos criar algo parecido para o nosso projeto? Bem, a boa notícia é que nós podemos, e Elixir nos permite fazer isso de um modo fácil.

Pra começar a brincadeira rode isso:

```shell
$ mix new hello

* creating README.md
* creating .gitignore
* creating mix.exs
* creating config
* creating config/config.exs
* creating lib
* creating lib/hello.ex
* creating test
* creating test/test_helper.exs
* creating test/hello_test.exs

Your Mix project was created successfully.
You can use "mix" to compile it, test it, and more:

cd hello
mix test

Run "mix help" for more commands.
```

Agora, no arquivo `lib/hello.ex` que o Mix criou para nós, vamos criar uma função simples que irá imprimir “Hello, World!”

```shell
defmodule Hello do
  @doc """
  Saída: `Olá, mundo!` Todas as vezes.
  """
  def say do
    IO.puts("Hello, World!")
  end
end
```

Vamos criar nossa tarefa Mix customizada. Crie um novo diretório e um arquivo hello/lib/mix/tasks/hello.ex

```shell
defmodule Mix.Tasks.Hello do
  use Mix.Task

  @shortdoc "Simplesmente executa a função Hello.say/0"
  def run(_) do
    # chamando nossa função de anteriormente Hello.say()
    Hello.say()
  end
end
```

Note que agora nós começamos o código do defmodule com `Mix.Tasks` e o nome que queremos usar para o nosso comando. Na segunda linha, colocamos use `Mix.Task`, que traz o comportamento `Mix.Task` no namespace. Então, declaramos uma função run que ignora quaisquer argumentos e, dentro dessa função, chamamos nosso módulo `Hello` e a função `say`.

Vamos verificar nossa tarefa Mix. Enquanto estivermos no diretório, ela deve funcionar. Na linha de comando, digite `mix hello` e então, devemos ver o seguinte:

```shell
$ mix hello
Hello, World!
```

O Mix é bastante amigável por padrão. Ele sabe que todos podem cometer um erro de ortografia, então ele usa uma técnica chamada “fuzzy string matching”(correspondência de strings difusas) para fazer recomendações:

```shell
$ mix hell
** (Mix) The task "hell" could not be found. Did you mean "hello"?
```

Referências:

Phoenix https://hexdocs.pm/phoenix/overview.html

Ecto https://elixirschool.com/en/lessons/specifics/ecto/

From Models to Context https://medium.com/adorableio/from-models-to-contexts-in-phoenix-1-3-0-1535d1d773b2

Tarefas Mix Customizadas · Elixir School https://elixirschool.com/pt/lessons/basics/mix-tasks/

