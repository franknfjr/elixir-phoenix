# Dia 3

Ciação de um pequeno de uma aplicação web simples com autenticação com o coherence e autorização com o policy wonk.

criação da aplicação

```elixir
mix phx.new blog
```

Primeiro iremo gerar um CRUD pelos gerador do Phoenix.

```elixir
mix phx.gen.htm Submit Post posts title body:text
```

Adicionar rotas, para o controlador dos posts.

```elixir
scope "/", Blog do
  pipe_through :browser
  get "/", PageController, :index
  resources "/posts", PostController
end
```

criação da base de dados.

```elixir
mix ecto.create
mix ecto.migrate
```