## Quais opções de macth não vai funcionar

```elixir
a​ = [2, 4, 6] # => a → [2, 4, 6] 
a​ = 4 # => a → 4 
4 = ​ b
# assuming prior assignment 
 
[​ a​ , b ] = [ 4, 6, 8 ]   
# ** (MatchError) no match of right hand side value: [4, 6, 8] 
# :erl_eval.expr/3 
 
a​ = [ [ 1, 2, 3 ] ] ​ #=> a → [[1, 2, 3]] 
[ ​ a . ​ .5 ] = [ 1..5 ] # => a → 1 
[​ a​ ] = [ [ 1, 2, 3 ] ] ​ #=> a → [1,2,3] 
 
[[​ a ]] = [ [ 1, 2, 3 ] ] 
# ** (MatchError) no match of right hand side value: [[1, 2, 3]] 
# :erl_eval.expr/3 

soma 14
```

## A variável "a" está vinculada ao valor 2. Qual das seguintes opções vai funcionar

```elixir
iex(1)> [a,b,a] = [2,4,2]
[2, 4, 2]
iex(2)> [a,b,a] = [2,1,4]
** (MatchError) no match of right hand side value: [2, 1, 4]
    (stdlib) erl_eval.erl:450: :erl_eval.expr/5
    (iex) lib/iex/evaluator.ex:249: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:229: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:207: IEx.Evaluator.eval/3
    (iex) lib/iex/evaluator.ex:94: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:24: IEx.Evaluator.init/4
iex(2)> b = 1
1
iex(3)> ^b = 2
** (MatchError) no match of right hand side value: 2
    (stdlib) erl_eval.erl:450: :erl_eval.expr/5
    (iex) lib/iex/evaluator.ex:249: IEx.Evaluator.handle_eval/5
    (iex) lib/iex/evaluator.ex:229: IEx.Evaluator.do_eval/3
    (iex) lib/iex/evaluator.ex:207: IEx.Evaluator.eval/3
    (iex) lib/iex/evaluator.ex:94: IEx.Evaluator.loop/1
    (iex) lib/iex/evaluator.ex:24: IEx.Evaluator.init/4
iex(3)> ^b = 1
1
iex(4)> ^b = 3-a
1

soma = 15
```

# Exercício

Execute o IEx. Crie e execute as funções que fazem o seguinte:

```elixir
list_concat = fn a , c -> a ++ c end

sum = fn a,b,c -> a+b+c end 
```