# Como desenvolver API's Phoenix e como consumi-las?

Como mostrado no dia 2 do nosso Curso de Elixir-Phoenix existe a possibilidade da criação de um projeto Phoenix do zero onde houveram custos, de tempo e principalmente paciência, porém, agora será introduzido a maneira ágil e veloz de se criar o seu projeto utilizando GERADORES.

Básicamente GERADORES, geram o que você solicita a ferramenta Mix, que relembrando é a ferramenta de construção que fornece tarefas para criar, compilar e testar projetos Elixir, gerenciando suas dependências e etc. Atualmente,existem várias tarefas específicas de mistura específica do Phoenix e do Ecto disponíveis para nós, podemos ve-las solicitando a ajuda do terminal interativo. Também podemos criar nossas próprias tarefas específicas do aplicativo,mas para agora isso está fora do nosso escopo atual.

➜ mix help | grep -i phx
mix local.phx          # Updates the Phoenix project generator locally
mix phx.digest         # Digests and compresses static files
mix phx.digest.clean   # Removes old versions of static assets.
mix phx.gen.channel    # Generates a Phoenix channel
mix phx.gen.context    # Generates a context with functions around an Ecto schema
mix phx.gen.embedded   # Generates an embedded Ecto schema file
mix phx.gen.html       # Generates controller, views, and context for an HTML resource
mix phx.gen.json       # Generates controller, views, and context for a JSON resource
mix phx.gen.presence   # Generates a Presence tracker
mix phx.gen.schema     # Generates an Ecto schema and migration file
mix phx.gen.secret     # Generates a secret
mix phx.new            # Creates a new Phoenix v1.3.0 application
mix phx.new.ecto       # Creates a new Ecto project within an umbrella project
mix phx.new.web        # Creates a new Phoenix web project within an umbrella project
mix phx.routes         # Prints all routes
mix phx.server         # Starts applications and their servers


Agora entrando no clima de geradores iremos iniciar a construção de APIs de um cenário real.

Suponhamos que você fez uma aplicação web super bacana em ReactJS, ou fez o nosso curso de ReactNative e possui um cliente que necessita consumir algumas informações via Json que contenha com um grau de restrição de acesso. O lance todo de ter a aplicação funcionando nesses contextos, é de que na verdade as informações nunca devem ser acessadas do banco de dados diretamente, e assim existem outras maneiras de se obter os dados vindo do servidor, onde a prática mais comum é a RESTful, que onde o Phoenix se encaixa.

Ao final do dia você terá construido:

* Adicionar usuários e dar a eles a capacidade de fazer login
* Gerenciar tokens de autenticação para os usuários
* Definir um pipeline para conceder acesso a rotas restritas apenas a solicitações autenticadas