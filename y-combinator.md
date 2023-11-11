---
layout: post
title: 'Y-Combinator in Mercury'
description: 'My ancient article revived from Blogspot'
---

# Y-Combinator in Mercury

_May 2011_

<sup>(This is an ancient article revived from my Blogspot. In those old times I was interested in the [Mercury](https://en.wikipedia.org/wiki/Mercury_(programming_language)) programming language)</sup>
  
From [Wikipedia]():

> In functional programming, the Y combinator can be used to formally define recursive functions in a programming language that does not support recursion.

```mercury
:- module y2.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module int.

:- type mu(A) ---> roll(unroll :: (func(mu(A)) = A)).

y(F) = F1(roll(F1)) :- F1 = (func(X) = (func(A) = F(unroll(X)(X))(A))).

y_fac = y(func(F) = (func(N) = (N =< 0 -> 1; N * F(N-1)))).
y_fib = y(func(F) = (func(N) = (N < 2 -> N; F(N-1) + F(N-2)))).

main -->
write_int((y_fac)(10)), % 3628800
nl,
write_int((y_fib)(10)). % 55
```

Compile & run:

```
$ mmc --infer-all y2
y2.m:015: Inferred :- func y(((func ((func V_2) = V_1)) = ((func V_2) = V_1)))
y2.m:015:   = ((func V_2) = V_1).
y2.m:017: Inferred :- func y_fac = ((func int) = int).
y2.m:018: Inferred :- func y_fib = ((func int) = int).

$ y2
3628800
55
```

Solution is based on Haskell/OCaml solutions from [Rosettacode](http://rosettacode.org/wiki/Y_combinator).

### Links

1. [http://en.wikipedia.org/wiki/Fixed_point_combinator](http://en.wikipedia.org/wiki/Fixed_point_combinator)
2. [http://rosettacode.org/wiki/Y_combinator](http://rosettacode.org/wiki/Y_combinator)

