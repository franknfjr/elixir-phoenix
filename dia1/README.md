# introdução ao Elixir

* Introdução ao Elixir:
  * Conceitos de Escalabilidade
  * Tolerância a falha
  * Linguagem funcional

* Tipos básico:
  * Booleans
  * Atoms
  * Strings
  * Listas
  * Maps
  * Tuplas
  * Palavra-chave

* Pattern Matching:
  * Atribuição
  * Ignorando valores
  * Matches complexos
  * Operador Pipe

* Função Anônima:
  * Funções e Pattern Matching
  * Case, cond e if
  * Funções retornando funções
  * Função recebendo função como argumento

* Modulo e Função Nomeada:
  * Função do end
  * Funções Privada
  * Modulo
  * Atributo de Módulo

## Conceitos de Escalabilidade

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

## Tolerança a falhas

Em software as falhas são decorrentes de desenvolvimentos de bugs e causados por humanos. As mesma são tratadas com basicamente com detectação e recuperação, e tecnicas de tolerancia a falhas.

Para lidar com falhas, o Elixir fornece supervisores que descrevem como reiniciar partes de seu sistema quando as coisas dão errado, voltando a um estado inicial conhecido que é garantido que funcione.

```elixir

children = [
TCP.Pool,
{TCP.Acceptor, port: 4040}
]
Supervisor.start_link(children, strategy: :one_for_one)
```

## Linguagem funcional

É um paradigma de programação onde não é tido para ao código com ele deve fazer, quando e como. Não será desenvolvido passo a passo, mas sim como uma sequência de funções e passos, as quais de maneira composta iram resolver problemas.

A programação funcional promove um estilo de codificação que ajuda os desenvolvedores a escrever códigos curtos, rápidos e de fácil manutenção. Por exemplo, a correspondência de padrões permite que os desenvolvedores desorganizem dados facilmente e acessem seu conteúdo.

```elixir

%User{name: name, age: age} = User.get("John Doe")
name #=> "John Doe"  
```

O Elixir depende muito desses recursos para garantir que seu software esteja funcionando sob as restrições esperadas. E quando não é, não se preocupe, os supervisores estão de prontidão.

## Tipos básicos

Em Elixir como em outras linguagens existes tipos como númericos, booleanos e coleções, mas ele trás alguns extras como atoms, binários e funções. É isso, funçãos também são tipos em elixir.

### Booleans

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
