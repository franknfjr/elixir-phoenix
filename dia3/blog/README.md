# Blog

Neste tutorial iremos criar um sistema simples que realiza autenticação utilizando o Coherence e autorização com o Policy wonk, a aplicação final será um blog simples.

* Gerar CRUD dos Post, cada Post possui titulo e o corpo da mensagem.

```elixir
mix phx.gen.html Submit Post posts title body:text
```

* No arquivo _routes.ex_ adicionar o novo resources dos posts, sem autenticação nenhuma primeiro

```elixir
scope "/", Blog do
  pipe_through :browser
  get "/", PageController, :index
  resources "/posts", PostController
end
```

* Criar a base de dados e migrar a tabela dos posts

```shell
mix ecto.create
mix ecto.migrate
```

* Adicionar a autenticação com o Coherence para proteger as ações do Post, no arquivo _mix.exs_, adicionar `{:coherence, "~> 0.5.2"}` nos _deps_ e na _application_ adicionar o `:coherence`.

```elixir
  def application do
    [
      mod: {Blog.Application, []},
      extra_applications: [:coherence, :logger, :runtime_tools]
    ]
  end


  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:plug_cowboy, "~> 1.0"},
      {:coherence, "~> 0.5.2"}    
    ]
  end
```

* Instalar as dependencias

```shell
run mix deps.get
```

* Executar o comando, para gerar os arquivos de configuração, views, controllers, ... do Coherence

```shell
mix coh.install --full-invitable
```


* Coherence pede para configurar as rotas, no arquivo _router.ex_ adicionar os seguintes comandos.

```elixir
defmodule BlogWeb.Router do
  use BlogWeb, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true     
  end

  # Add this block
  scope "/" do
    pipe_through :browser
    coherence_routes()
  end

   # Add this block
   scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/", BlogWeb do
    pipe_through :browser # Use the default browser stack   
    get "/", PageController, :index   
  end

  scope "/", BlogWeb do
    pipe_through :protected
    # Add protected routes below 
    # ADICIONAR AQUI NESSE SCOPE AS ROTAS
    # QUE QUERERMOS PROTEGER
          
  end

  # Other scopes may use custom stacks.
  # scope "/api", BlogWeb do
  #   pipe_through :api
  # end
end

```

* O Coherence cria um usuário dummy para o sistema, entao vamos adicionar alguns usuários para teste. No arquivo _priv/repo/seeds.exs_ adicionar:

```elixir
Blog.Repo.delete_all Blog.Coherence.User

Blog.Coherence.User.changeset(%Blog.Coherence.User{}, %{name: "seunome", email: "seunome@seunome.com", password: "123123", password_confirmation: "123123"})
|> Blog.Repo.insert!

Blog.Coherence.User.changeset(%Blog.Coherence.User{}, %{name: "seuoutronome", email: "seuoutronome@seuoutronome.com", password: "123123", password_confirmation: "123123"})
|> Blog.Repo.insert!
```

* Migrar e rodar os seeds

```shell
mix ecto.setup
```

* Para simplificar o exemplo, vamos proteger todas as ações do CRUD Post.

```elixir
  scope "/", BlogWeb do
    pipe_through :protected
    # Add protected routes below
    # ADICIONAR AQUI NESSE SCOPE AS ROTAS
    # QUE QUERERMOS PROTEGER    
    resources "/posts", PostController
          
  end
```

* Vamos adicionar o menu de navegação, no arquivo _web/templates/layout/app.html.eex_ , adicione o seguinte trecho de código no header.

```html
      <header class="header">
        <nav role="navigation">
          <ul class="nav nav-pills pull-right">
            <%= if Coherence.current_user(@conn) do %>
              <%= if @conn.assigns[:remembered] do %>
                <li style="color: red;">!!</li>
              <% end %>
            <% end %>     
            <li><a href="/registrations/new">Sign up</a></li>
            <li><a href="/sessions/new">Login</a></li>            
          </ul>
        </nav>
      <span class="logo"></span>       
    </header>
```


* É hora de testar o sistema. Rode no terminal o comando `mix phx.server` e acesse _http://localhost:4000/posts_ somente um usuário logado terá acesso as ações dentro da aplicação.

Um problema é que usuários podem editar, visualizar e deletar posts de outros usuários. Vamos tratar disso na autorização com Policy Wonk


# Autorização - Policy Wonk.

* Adicionar no arquivo _mix.exs_ a dependencia `{:policy_wonk, "~> 0.2.0"}`.

```elixir
defp deps do
  [{:phoenix, "~> 1.2.1"},
   {:phoenix_pubsub, "~> 1.0"},
   {:phoenix_ecto, "~> 3.0"},
   {:postgrex, ">= 0.0.0"},
   {:phoenix_html, "~> 2.6"},
   {:phoenix_live_reload, "~> 1.0", only: :dev},
   {:gettext, "~> 0.11"},
   {:cowboy, "~> 1.0"},
   {:coherence, "~> 0.3"},
   {:policy_wonk, "~> 0.2.0"}]
end
```

* Instalar a dependência

```shell
mix deps.get
```

* Configurar o Policy Wonk, no arquivo _config.exs_ adicionar:

```elixir
config :policy_wonk, PolicyWonk,
  policies: Blog.Policies
```

* Criar o arquivo _/lib/blog_web/policies.ex_ , porém vamos sobre-escrever essa policy no controller.

```elixir
defmodule Blog.Policies do
    use PolicyWonk.Enforce   

    @behaviour PolicyWonk.Policy
  
    @err_handler Blog.ErrorHandlers
  
    def policy( assigns, :current_user) do
      case assigns[:current_user] do
        _user = %Blog.Coherence.User{} -> :ok
        _ -> :current_user
      end
    end
  
    def policy_error(conn, error_data) when is_bitstring(error_data), do: @err_handler.unauthorized(conn, error_data)
  
    def policy_error(conn, error_data), do: policy_error(conn, "Unauthorized")
  end
```

* É necessário fazer a associação entre Posts e Users, gerar a migration:

```shell
mix ecto.gen.migration add_user_id_to_posts
```

```elixir
defmodule Blog.Repo.Migrations.AddUserIdToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
```

* Associar no schema Post, no arquivo _web/models/post.ex_ editar:

destaque para as linhas: `belongs_to :user, Blog.Coherence.User` e  `post
    |> cast(attrs, [:title, :body, :user_id])`

```elixir
defmodule Blog.Submit.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Submit.Post

  schema "posts" do
    field :body, :string
    field :title, :string

    belongs_to :user,  Blog.Coherence.User
    timestamps()
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:title, :body, :user_id])
    |> validate_required([:title, :body])
  end
end

```

* O arquivo _lib/blog/coherence/user.ex_ deve ficar assim:

destaque: `has_many :posts, Blog.Submit.Post`

```elixir
defmodule Blog.Coherence.User do
  @moduledoc false
  use Ecto.Schema
  use Coherence.Schema 
  

  schema "users" do
    field :name, :string
    field :email, :string
    has_many :posts, Blog.Submit.Post
    coherence_schema()

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :email] ++ coherence_fields())
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_coherence(params)
  end

  def changeset(model, params, :password) do
    model
    |> cast(params, ~w(password password_confirmation reset_password_token reset_password_sent_at))
    |> validate_coherence_password_reset(params)
  end
end
```

* A relação entre as duas entidades foi estabelecida.


* Criar o arquivo de erro `error_handlers.ex` na raiz da pasta _lib/blog_web_

```elixir
defmodule BlogWeb.ErrorHandlers do
  use BlogWeb, :controller
  import BlogWeb.Router.Helpers

  def unauthorized(conn, error_str \\ nil ) do
    conn
    |> put_flash(:error, error_str || "Unauthorized")
    |> redirect(to: session_path(conn, :new))
    |> halt()
  end

  def resource_not_found(conn, _error_str \\ nil) do
    conn
      |> put_status(404)
      |> put_view(BlogWeb.ErrorView)
      |> render("404.html")
      |> halt()
  end

end
```

* Agora precisamos adicionar no contexto `Submit.ex` que iremos gerenciar um post do usuário.

```elixir
alias Blog.Submit.Post
alias Blog.Coherence.User
.
.
.

def list_posts do
    query = from p in Post,
          join: u in User, where: p.user_id == u.id
    Repo.all(query)
end

.
.
.

def create_post(post, attrs \\ %{}) do
    post
    |> Ecto.build_assoc(:posts)
    |> Post.changeset(attrs)
    |> Repo.insert()
end

```

* Após isso, adicionar os plugs no inicio do `post_controller.ex`
```elixir
efmodule BlogWeb.PostController do
  use BlogWeb, :controller

  alias Blog.Submit
  alias Blog.Submit.Post
  alias Blog.Coherence.User

  plug PolicyWonk.LoadResource, [:post] when action in [:edit, :update, :delete]
  plug PolicyWonk.Enforce, :post_owner when action in [:edit, :update, :delete]
  .
  .
  .
  def policy(assigns, :post_owner) do
    case {assigns[:current_user], assigns[:post]} do
      {%Blog.Coherence.User{id: user_id}, post=%Blog.Submit.Post{}} ->
        case post.user_id do
          ^user_id -> :ok
          _ -> :not_found
        end
      _ -> :not_found
    end
  end

  def policy_error(conn, :not_found) do
    BlogWeb.ErrorHandlers.resource_not_found(conn, :not_found)
  end

  def load_resource(_conn, :post, %{"id" => id}) do
    case Submit.get_post!(id) do
      nil -> :not_found
      post -> {:ok, :post, post}
   end
end
```
