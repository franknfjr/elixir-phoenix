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

No seu arquivo o nome dado ao seu aplicativo ficará no lugar de `App` isso vale para o módulo do `router` e `controller`. A primeira linha desse módulo `use AppWeb, :router`, torna as funções do router Phoenix disponível em nosso router específico.

## Plug

É composto de módulos ou funções reutilizáveis para construir aplicações web, oferece procedimento discreto, como análise ou registro de cabeçalho de solicitação. Pode ser gravado para tratar quase tudo, desde a autenticação até o pré-processamento de parâmetros e até a renderização.

Phoenix extrai grande proveito do Plug em geral, principalmente o Router e o Controller.

## Ecto