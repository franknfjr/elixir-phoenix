# Introdução ao Elixir:

* Conceitos de Escalabilidade
* Tolerância a falha
* Linguagem funcional

# Tipos básico:

* Booleans
* Atoms
* Strings
* Listas
* Maps
* Tuplas
* Palavra-chave

# Pattern Matching:

* Atribuição
* Matches complexos

# Função Anônima:

* Funções e Pattern Matching
* if, unless, cond e case
* Guard Clauses
* Funções retornando funções
* Função recebendo função como argumento

# Módulo e Função Nomeada:

* Módulo
* Função do end
* Funções Privada  
* Atributo de Módulo
* Operador Pipe

# Conceitos de Escalabilidade

Escalabilidade é basicamente a capacidade de expanção sem aumento elevado do custo. Em engenharia de software é uma caracteristica desejavel em todo o sistema, que indica sua capacidade de manipular uma porção crescente de trabalho de forma uniforme, ou estar preparado para crescer.
Em elixir todo o código é executado dentro de threads de execução leves (chamados processos) que são isolados e trocam informações por meio de mensagens.

```elixir

current_process = self()

# Spawn an Elixir process (not an operating system one!)
spawn_link(fn ->
send current_process, {:msg, "hello world"}
end)

# Block until the message is received
receive do
{:msg, contents} -> IO.puts contents
end
```

# Tolerança a falhas

Em software as falhas são decorrentes de desenvolvimentos de bugs e causados por humanos. As mesma são tratadas com basicamente com detectação e recuperação, e tecnicas de tolerancia a falhas.

Para lidar com falhas, o Elixir fornece supervisores que descrevem como reiniciar partes de seu sistema quando as coisas dão errado, voltando a um estado inicial conhecido que é garantido que funcione.

```elixir

children = [
TCP.Pool,
{TCP.Acceptor, port: 4040}
]
Supervisor.start_link(children, strategy: :one_for_one)
```

# Linguagem funcional

É um paradigma de programação onde não é tido para ao código com ele deve fazer, quando e como. Não será desenvolvido passo a passo, mas sim como uma sequência de funções e passos, as quais de maneira composta iram resolver problemas.

A programação funcional promove um estilo de codificação que ajuda os desenvolvedores a escrever códigos curtos, rápidos e de fácil manutenção. Por exemplo, a correspondência de padrões permite que os desenvolvedores desorganizem dados facilmente e acessem seu conteúdo.

```elixir

%User{name: name, age: age} = User.get("John Doe")
name #=> "John Doe"  
```

O Elixir depende muito desses recursos para garantir que seu software esteja funcionando sob as restrições esperadas. E quando não é, não se preocupe, os supervisores estão de prontidão.

# Tipos básicos

Em Elixir como em outras linguagens existes tipos como númericos, booleanos e coleções, mas ele trás alguns extras como atoms, binários e funções. É isso, funçãos também são tipos em elixir.

## Booleans

Elixir apresenta três maneiras de expressões booleans: `true`, `false` e `nil` avaliado como false em contextos booleanos).

```elixir

iex> true
true

iex> false
false

iex> nil
nil
```

O Elixir fornece várias funções de predicado para verificar um tipo de valor. Por exemplo,a is_boolean/1função pode ser usada para verificar se um valor é booleano ou não.

```elixir

iex> is_boolean(true)
true

iex> is_boolean(1)
false
```

Você também pode usar is_integer/1, is_float/1ou is_number/1verificar, respectivamente, se um argumento é um inteiro, um float ou qualquer um.

```elixir

iex(4)> is_integer(1)
true
iex(5)> is_integer(1.5)
false
```

## Atoms

Um Átomo é uma constante cujo o nome é seu valor. em Elixir ele é representado por `:` (dois pontos) em seguida um texto. Geralmente atoms são mais comuns para sinalizar alguma mensagem como de erro ou sucesso.

```elixir

iex> :ok
:ok

iex> :error404
:error404

iex> :ok == :error
false
```

Os booleanos truee false são, na verdade, atoms.

```elixir

iex> true == :true
true

iex> is_atom(false)
true

iex> is_boolean(:false)
true
```

Agumas funções para lidar com atoms.

```elixir
iex(1)> Atom.to_string(:curso)
"curso"

iex(2)> String.to_atom("Curso")
:Curso
```

## String

São caracteres UTF-8 envolvidas por aspas duplas. Além disso elas tem escritas diretamente com quebras de linha, aceitam heredoc (documentação entre caracteres de abertura e fechamento) e interpolação — que vai além da interpolação comum porque permite realizar operações diretamente dentro dela.

```elixir

iex(1)> "Curso de Elixir e Phoenix"
"Curso de Elixir e Phoenix"

iex(2)> "Cruso de Elixir
...(2)> de Phoenix"
"Curso de Elixir\ne Phoenix"

iex(3)> IO.puts("Curso de Elixir\ne Phoenix")
Curso de Elixir
e Phoenix
:ok

iex(4)> a = "Elixir e Phoenix"
"Elixir e Phoenix"

iex(5)> "Curso de #{a}"
"Curso de Elixir e Phoenix"

iex(6)> "2 + 2 é igual a #{2 + 2}"
"2 + 2 é igual a 4 "
```

Algumas função reverse do módulo String , com o nome bem sugestivo, pode inverter seus caracteres.

```elixir

iex(1)> String.reverse("Curso elixir")
"rixile osruC"  
```

A função length pode nos dar a quantidade de caracteres ou tamanho da string.

```elixir

iex(2)> String.length("Curso elixir")
12
```

## Lista

Listas é um tipo de coleção de elementos e podem conter diversos outros tipos dentro dela. Como ter uma listas de números, atoms e string. A mesma não deve ser comparada    com array de outras linguagens, pois a lista pode ser formada por head (cabeça) e tail(calda). Onde na head contem o valor e tail é a lista inteira. Por ser implementada dessa forma pode percorrida facilmente.

```elixir

iex(1)> ["Curso", 1, 1.5, true, nil, :ok]
["Curso", 1, 1.5, true, nil, :ok]
```

Em elixir podemos fazer concatenação de lista com a função `++/2`.

```elixir

iex(1)> [2,4,5,6] ++ [:ok, true, "Elixir"]
[2, 4, 5, 6, :ok, true, "Elixir"]

iex(2)> lista = [1,3,7,8]
[1, 3, 7, 8]

iex(3)> nova_lista = [2,4,5,6 | lista] |> Enum.sort
[1, 2, 3, 4, 5, 6, 7, 8]
```

Além de somar podemos subtrair com a função `--/2`.

```elixir

iex(1)> [2,4,6,8,10] -- [2,10]
[4, 6, 8]

iex(3)> nova_lista = [1,2,3,4,5,6,7,8,9] -- lista
[4, 5, 6, 7, 8, 9]
```

Lembra que uma lista tem head (cabeça) e tail (calda), existe as funções hd/1 e tl/1, para pega-las.

```elixir

iex(4)> hd([2,4,6,8,10])

iex(5)> tl([2,4,6,8,10])
[4, 6, 8, 10]
```

## Map

O `map` no elixir é uma estrutura de valor-chave, para criar um usa a sintaxe `%{}`. Seus valores podem ser acessado através das suas chaves.

```elixir

iex(1)> mapa = %{"chave1" => 1, :chave2 => "curso", :chave3 => "Phoenix"}
%{:chave2 => "curso", :chave3 => "Phoenix", "chave1" => 1}

iex(2)> mapa1 = %{chave1: 1, chave2: 2, chave3: "Elixir"}
%{chave1: 1, chave2: 2, chave3: "Elixir"}

iex(3)> mapa2 = %{"mesmaChave" => 1, "mesmaChave" => "Curso"}
%{"mesmaChave" => "Curso"}
```

Para acessar os valores do mapa usamos `mapa[chave]`, caso nossa chave seja uma atom podemos acessar da seguinte forma `mapa.chave`.

```elixir

iex(4)> mapa["chave1"]
1

iex(5)> mapa.chave2
"curso"

iex(6)> mapa.chave3
"Phoenix"

iex(7)> mapa1[:chave1]
1

iex(8)> mapa1[:chave2]
2

iex(9)> mapa1[:chave3]
"Elixir"
```

## Tuplas

Uma estrutura parecidas com a lista, elas armazenam qualquer valores dentro delas. Sua sintaxe é `{}`.
Tem uma vantagem em relação a lista quando acessamos elementos idividuais, mas crescer e adcionar mais elementos com o tempo pode se tornar custoso.

```elixir

iex(11)> {1, "Curso", "Phoenix", true, :ok, [1,2,3]}
{1, "Curso", "Phoenix", true, :ok, [1, 2, 3]}
```

Elixir tem funções diversas funções para trabalhar com tuplas, mas irei mostrar duas delas, a tuple_size/1 que acessa o tamanho da tupla, a elem/2 que nos dá a possibilidade de acessar seus elementos pelo indice e put_elem/3 que permite atualizar elemento.

```elixir

iex(14)> tuple_size tupla
6
iex(15)> elem tupla, 4
:ok
iex(16)> elem tupla, 0
1

iex(1)> tupla = {:frank, 22}
{:frank, 22}  
iex(2)> put_elem tupla, 1, 23
{:frank, 23}
```

## Palavra Chave

Essa é uma lista especial composta por dois elementos, onde o primeiro é um atom. As palavras-chaves compartilham o desempenho da lista e geralmente são usadas para passar alternativas a funções.

```elixir

iex(1)> [Curso: "Phoenix", Elixir: "linguagem"]
[Curso: "Phoenix", "Elixir": "linguagem"]

iex(2)> [{:Curso, "Phoenix"}, {:Elixir, "linguagem"}]
[Curso: "Phoenix", "Elixir": "linguagem"]
```

Existem três principais relevancias da palavra-chave ou lista de palavra-chave:

* As chaves são atoms;
* Elas estão ordenadas;
* e não são unicas;

# PATTERN MATCHING

Suas principais funcionalidades são atribuir valores, procurar padrões em valores, estruturas de dados e funções, comparar diferentes tipos e separar estruturas complexas em estruturas mais simples.

## Atribuições

Em elixir o operador `=` pode ser usado para atribuir variáveis.

```elixir

iex(5)> x = 2
2
```

Quando atribuimos o valor `2` a variável `x`, na verdade o que esta acontecendo é uma checagem de padrões, não se diz x igual a 2 e sim x macth 2, estamos tentando casar o valor do lado esquerdo com o do lado direito.

```elixir

iex(6)> x = 2
2
iex(7)> 2 = x 
2
iex(8)> 3 = x
** (MatchError) no match of right hand side value: 2
```

## Matches Complexos

Vamos usar o operador `=` com estruturas mais complexas.

```elixir

iex(20)> {:curso, nome} = {:curso, "Phoenix"}
{:curso, "Phoenix"}
iex(21)> nome  
"Phoenix"

#Se tentarmos casar atoms diferentes, o match não acontece e temos erro.
iex(22)> {:curso, nome} = {:treinamento, "Elixir"} 
** (MatchError) no match of right hand side value: {:treinamento, "Elixir"}
```

Podemos usar o `_` (underscore) para pular um valor que não interessa. Caso queira pegas apenas um valor ou valores específicos de dentro de uma estrutura.

```elixir

iex(22)> {_, numero} = {"não quero", 200 }
{"não quero", 200}
iex(23)> numero
200

iex(24)> {_, numero, _} = {1,2,3}
{1, 2, 3}
iex(25)> numero
2
```

Tem a possibilidade de fazer o macth com o caractere `^` conhecido como operador `Pin`, com ele impedimos que o processo faça a religação de um valor a uma variável (rebind), tornando-a completamente imutável.

```elixir

iex(1)> [a, c] = [4,6]
[4, 6]
iex(2)> a + c
10
iex(3)> [a, c] = [3, 5]
[3, 5]
iex(4)> a + c
8
iex(5)> [^a, c] = [8, 10]
** (MatchError) no match of right hand side value: '\b\n'

iex(5)> [^a, c] = [3, 10]
[3, 10]
iex(6)> a
3
iex(7)> c
10
iex(8)>
```

Exercicios

### Quais opções de macth não vai funcionar

1. a = [2, 4, 6]
2. a = 4
3. 4 = b
4. [a, b] = [ 4, 6, 8 ]
5. a = [ [ 1, 3, 5 ] ]
6. [a] = [ [ 6, 8, 10 ] ]
7. [[a]] = [ [ 1, 2, 3 ] ]

Some as opções que não funcionaram e de a resposta.

### A variável "a" está vinculada ao valor 2. Qual das seguintes opções vai funcionar

1. [ a, b, a ] = [ 2, 4, 2 ]
2. [ a, b, a ] = [ 2, 1, 4 ]
3. b = 1
4. ^b = 2
5. ^b = 1
6. ^b = 3 - a

Some as opções que funcionaram e de a resposta.

# Função Anônima

Como o `Elixir` é uma linguagem funcional, não é de se admirar que uma função é um tipo básico. A função anônima é um tipo de função tão específica e auto explicativa que não é necessário criar um nome. 

Para criar uma precisa usar a palavra-chave `fn` para dar inicio, acrescentar os argumentos desejados, em seguida seta `->` contendo o corpo da função e para finalizar `end`.

```elixir

iex(22)> soma = fn (n1, n2) -> n1 + n2 end 
#Function<12.99386804/2 in :erl_eval.expr/5>
iex(23)> soma.(3,4)
7

iex(1)> curso = fn -> IO.puts "Elixir" end
#Function<20.99386804/0 in :erl_eval.expr/5>
iex(2)> curso.()
Elixir
:ok
iex(3)> f1 = fn a, b -> a * b end 
#Function<12.99386804/2 in :erl_eval.expr/5>
iex(4)> f1.(5,3)
15

```

Diferentes as funções nomeadas que veremos a seguir, para usarmos uma função anônima têm que usar o ponto `.` e passar os parâmetros entre parênteses `()`. A mesma é ligada pelo macth a uma variável que será utilizada em algum momento.

Podemos usar `&` para abreviar funções anônimas, os `()` são usados como corpo e os parametros serão `&1, &2`.

```elixir

iex> sum = &(&1 + &2)
iex> sum.(4, 3)
7
``` 

## Função e Pattern Matching

O Elixir não usa pattern matching apenas para variáveis, mais também para corresponder valores em funções, quando chamamos a função sum.(4,3) e passamos os argumentos 4 e 3, o elixir verifica as possíveis ligações e faz a correspondecia de valores &1 = 4 e &2 = 3. É o mesmo processo de quando escrevemos `{a,b} = {7,8}`.

Sendo assim podemos usar correspondecia de padrões mais complexas quando chamamos uma função.

```elixir

iex> troca = fn {c, d} -> {d, c} fim
#Function <12.17052888 em: erl_eval.expr / 5>
iex> swap. ({10, 11})
{11, 10}
```

Na função acima utiliza 2 parametros `c e d` no seu corpo é feita troca dos valores para `d e c`. Ao chamar a função `troca` e passar os valores é feito o match `10 = d e 11 = c`. 

Em elixir a função ter varias assinaturas, isso por causa do reconhecimento de padrões. No exemplo que será mostrado a função terá dois assinaturas ou corpos. Sabe-se que na função a seguir a tupla retornada por File.open tem `:ok`, seu primeiro elemento se o arquivo foi aberto, então escrevemos uma função que exibe a primeira linha de um arquivo aberto com sucesso ou uma mensagem de erro simples se o arquivo não pôde ser aberto.

```elixir

iex> handle_open = fn
2 ...> {:ok, file} -> "Read data: #{IO.read(file, :line)}"
3 ...> {_, error} -> "Error: #{:file.format_error(error)}"
4 ...> end
5 #Function<12.17052888 in :erl_eval.expr/5>
6 iex> handle_open.(File.open("code/intro/hello.exs")) # this file exists
7 "Read data: IO.puts \"Hello, World!\"\n"
8 iex> handle_open.(File.open("nonexistent")) # this one doesn't
9 "Error: no such file or directory"
```   

## Exercicios

Execute o IEx. Crie e execute as funções que fazem o seguinte:

1. list_concat.([1, 2], [3, 4]) #=> [1, 2, 3, 4]
2. sum.(4, 6, 8) #=> 18
3. tupla_para_lista.( { 1357, 2468 } ) #=> [ 1357, 2468 ]


Escreva uma função que receba três argumentos. Se os dois primeiros forem zero, retorne "ElixirPhoenix". Se o primeiro for zero, retorne "Elixir". Se o segundo for zero, retorne "Phoenix". Caso contrário, retorne o terceiro argumento. Não use nenhum recurso de idioma que ainda não tenhamos abordado neste livro.

## if, unless, cond e case

Em elixir essas construções não são especiais como em outras linguagens, elas são conhecidas como macros que são funções básicas. Tentem não usar tanto esses controle de fluxo, pois quanto menos controle de fluxo dentro das funções, tera um código mais focado e curto.

## if e unless

Como já conhecem o `if` em elixir o `unless` e como sé fosse o contrario. No caso do `if` ele verifica se a condição é verdade e o `unless` verifica se é falsa.

```elixir

iex> if 5 == 5, do: "é verdade!", else: "é falso!"
"é verdade!"

iex> if 1 == 2, do: "é verdade!", else: "é falso!"
"é falso!"

iex> if 1 == 1 do
...> "é verdade!"
...> else
...> "é falso!"
...> end
é verdade!
```

Unless é parecido:

```elixir

iex> unless 1 == 1, do: "falso", else: "OK"
"OK"
iex> unless 1 == 2, do: "OK", else: "falso"
"OK"
iex> unless 1 == 2 do
...> "OK"
...> else
...> "error"
...> end
"OK"
```

## Cond

Essa macro da a possibilidade de encontrar a primeira condição valida no meio de várias condições.

```elixir

iex(6)> cond do
...(6)> 2 + 2 == 5 -> "Isso não é verdade"
...(6)> 2 + 2 == 6 -> "Isso também não é verdade"
...(6)> 2 + 2 == 4 -> "Eeeee é verdade!"
...(6)> end
"Eeeee é verdade!"
```

## Case

Essa macro nos permite tentar casar um valor com um conjunto de padrões, isso é feito até achar um correspondente e o efetue o match de forma correta.

```elixir

case File.open("elixirphoenix.ex") do
{ :ok, file } ->
IO.puts "Primeira linha é: #{IO.read(file, :line)}"
{ :error, reason } ->
IO.puts "Falha ao tentar abrir o arquivo: #{reason}"
end
```

```elixir

iex(2)> case "elixir" do
...(2)> "Phoenix" -> "elixir não é Phoenix"
...(2)> "Java" -> "elixir não é Java"
...(2)> _  -> "elixir não é underscore, mas underscore é um coringa que casa com tudo beleza?"
...(2)> end
"elixir não é underscore, mas underscore é um coringa que casa com tudo beleza?"
```

## Guard Clauses

São experessões implementadas que certificam que determinada função receba somente um tipo de argumento, validar o argumento.

```elixir

iex(1)> case {4,6,8} do
...(1)> {4,x,8} when x > 0 -> "Isso vai casar porque 6 é maior que zero"
...(1)> _ -> "Isso casaria se não tivesse casado antes"
...(1)> end
"Isso vai casar porque 6 é maior que zero"
```

## Funções retornando funções

Aqui basicamente temos uma variável que recebe uma função e o corpo dessa função é uma outra função. Segue um exemplo simples de funções sem argumentos.

```elixir

iex> fun_r_fun = fn -> fn -> "Elixir" end end
#Function<12.17052888 in :erl_eval.expr/5>
iex> fun_r_fun .()
#Function<12.17052888 in :erl_eval.expr/5>
iex> fun_r_fun .().()
"Elixir"
```

Quando é chamado a função externa `fun_r_fun.()` é retornado a função interna, e quando se chama `fun_r_fun.().()` a função interna é examinada e retorna "Elixir".

Pode-se usar parênteses para tornar a função externa mais evidente.

```elixir

iex(6)> funcao = fn -> (fn -> "Phoenix" end) end
#Function<20.99386804/0 in :erl_eval.expr/5>
iex(7)> outra = func
funcao                  function_exported?/3
iex(7)> outra = funcao.()
#Function<20.99386804/0 in :erl_eval.expr/5>
iex(8)> outra.()
"Phoenix"
```

## Função recebendo função como argumento

O código em `Elixir` tem a capacidade de passar funções em quase todo lugar, inclusive como argumento de uma função.

```elixir

iex> tempo = fn n -> n * 4 end
#Function<12.17052888 in :erl_eval.expr/5>
iex> use = fn (fun, value) -> fun.(value) end
#Function<12.17052888 in :erl_eval.expr/5>
iex> use.(tempo, 6)
24
```

`Use`é uma função que utiliza uma segunda função mais um valor e exibe um resultado. Temos o módulo interno da liguagem o `Enum` que tem uma função chamada `map`. Essa função recebe dois argumentos, sendo um coleção e o outro uma função.

```elixir

iex(1)> lista = [2,4,6,8, 10]
[2, 4, 6, 8, 10]
iex(2)> Enum.map lista, fn elem ->  elem * 2 end
[4, 8, 12, 16, 20]
```

É retornado uma lista que é o resultado de execução da função para cada elemento da lista.

# Módulo é Função nomeada

## Módulo

A medida que seu código cresce a tendência é organiza-lo. Com `Elixir` isso fica fácil, para fazer isso, deve-se separar o código em funções e organizar essas dentro de módulos.

E por padrão as funções nomeadas em `Elixir` devem está dentro de módulos.

```elixir

defmodule Times do
  def double(n) do
    n * 2
  end
end
```

Como observado no exemplo acima, para criar um módulo basta usar a palavra reservada `defmodule` em seguida nome do módulo e dentro dele as funções.

Para compilar um módulo, pode-se fazer das seguintes formas:

Caso esteja forá do iex.

```elixir

$ iex times.exs
iex> Times.double(2)
4
```

Caso esteja no iex.

```elixir

iex(1)> c "times.exs"
[Times]
iex(2)> Times.double(8)
16
```

## Função end do

Podmeos escrever funções nomeadas de duas formas: com `do e end` e apenas em uma linha com `do`.

```elixir

# do end
def double(n) do
  n * 2
end

def double(n), do: n * 2
```

Se tentamos passar um tipo diferente dentro da função double retornará um erro.

```elixir

iex(2)> Times.double("Elixir")
** (ArithmeticError) bad argument in arithmetic expression times.exs:3: Times.double/1
```

O erro diz que tentamos realizar aritmética em uma string. Mas além disso ele escreve nossa função como Times.double/1, esse `1` que dizer que essa função tem aridade um, recebe um parâmetro. Se escrevermos uma função double com 3 parâmetros double/3, para o elixir são funções totalmente diferentes apesar de possuirem o mesmo nome. As funções nomeadas são identificadas tanto pelo nome, como pelo número de parâmetros (aridade).

### Exercício

1. Estenda o módulo Times com uma tripla função que multiplica seu parâmetro por três.

2. Execute o resultado no IEx. Use as duas técnicas para compilar o arquivo.

3. Adicione uma função quádrupla. (Talvez possa chamar a dupla função ...)

## Função Privada

Essas funções só podem ser chamadas dentro do módulo a qual foram declaradas. Para criar uma ultiliza a macro `defp` isso indica que é uma função privada. Se tentar execultar uma delas fora do módulo será retornado um erro que a função não existe.

```elixir

defmodule Privade do
  def fun(a) when is_list(a), do: true
  defp fun(a), do: false
end
```

## Atributo de Módulo

Em Elixir o atributo é utilizado normalmente onde programados Ruby ou Java podem empregar constantes. Eles não são variáveis convencionais, usa-se apenas para configuração e metadados. Os módulos Elixir possui metadados associados, cada item de metadados é chamado de atributo do módulo e reconhecido por um nome. Ao prefixar o nome com "@", pode acessa-lo.

```elixir

defmodule Exemplo do
    @autor "Frank Nascimento"
    def get_autor do
        @autor
    end
end

iex(1)> c ("atributos.ex")
[Exemplo]
iex(2)> IO.puts"Exemplo foi escrito por #{Exemplo.get_autor}"
Exemplo foi escrito por Frank Nascimento
:ok
```

## Operador Pipe

Esse operador `|>` tem como função passar o resultado de uma expressão com argumento para outra.

Aninhar funções é algo que pode se tornar confuso, ainda mais quando essas chamadas de funções ficam incorporadas em tal intensidade que torna-se muito difícil de acompanhar.

Irei usar o módulo Enum e suas funções `map` e `filter`, será criada uma coleção, o `map` sevirá para criar uma nova coleção e o `filter` volta a coleção, somente os elementos que passada a função retorne true. 

```elixir

iex(1)> colecao = [5,6,7,8,9]
[5, 6, 7, 8, 9]
iex(2)> Enum.filter(Enum.map(colecao, &(&1 * 3)), &(&1>20))
[21, 24, 27]
```

Para entender o que esta acontecendo, tem que ler da direita para esquerda, de dentro para fora. Com o operador `Pipe` ocorre da esquerda para direita, de fora para dentro. Tornando o entendimento e escrita mais simples.

```elixir

iex(3)> Enum.map(colecao, &(&1 * 3)) |> Enum.filter(&(&1 > 20))
[21, 24, 27]
```

Observe que na função `filter` está sendo passado somente a função anônima, pois o operador `Pipe` passou de forma automática o resultado da função `map`, como primeiro argumento.

### Exercício

1. Criar uma lista com 10 itens, aplicar imposto de 5% em cada um dos produtos, e depois filtramos somente os que têm valor superior a R$ 20,00. Por fim, somamos todos estes valores e mostramos o resultado na tela, tudo utilizando o que aprendemos junto com o pipe.

obs.: os intens ficam dentro de maps %{produto: "descrição", valor: 0.0}

Referências:

Introduction - Elixir https://elixir-lang.org/getting-started/introduction.html

Elixir School https://elixirschool.com/pt/

Elixir: Do zero à concorrência https://www.amazon.com.br/Elixir-Do-zero-%C3%A0-concorr%C3%AAncia-ebook/dp/B06Y5SWJR8?tag=goog0ef-20&smid=A18CNA8NWQSYHH&ascsubtag=go_1366271959_58245915327_265589414315_pla-441178693417_c_

Programming Elixir 1.3 https://www.amazon.com.br/Programming-Elixir-1-3-Dave-Thomas/dp/168050200X?tag=goog0ef-20&smid=A1ZZFT5FULY4LN&ascsubtag=go_1157433115_58530734048_257324212232_pla-301112824450_c_
