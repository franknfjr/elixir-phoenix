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
* Tarefas MIX

# O que é o Phoenix?

É um framework web escrito em Elixir, com padrão MVC do lado do servidor. Tem conceitos e componentes parecidos com outros frameworks web como o Ruby on Rails ou Django do Python. 

Uma das vantagens que o Phoenix proporciona é a alta produtividade do desenvolvedor e alto desempenho de aplicativos. Os canais para implementar recurso em tempo real e modelos pré-compilados que possibilitam uma velocidade incrível.

Nesse curso será tratado das partes que o compõem e as camadas adjacentes que o suportam. O mesmo é composto de varias partes distintas, cada um desses tem sua finalidade e parte a exercer na criação de uma aplicação web.

##Router

O `Router` tem como principais funções corresponder ás solicitações HTTP para ações do `controller`, conectam os manipuladores do canal e define uma série de transformações de pipeline para o middleware de definição de escopo para conjuntos de rotas.  

