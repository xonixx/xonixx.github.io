---
title: 'AWK technical notes'
description: "You'll learn why AWK doesn't have a GC and understand some peculiarities in its syntax" 
image: parameterized_goals1.png
---
[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://stand-with-ukraine.pp.ua)

# AWK technical notes
   
In the previous article [Fascination of AWK](awk.md) we discussed why AWK is great for prototyping and is often the best alternative to the shell and Python. In this article I want to show you some interesting technical facts I learned about AWK. 

## Lack of GC
AWK was designed to not require a GC (garbage collector) for its implementation. By the way, just like sh/bash.
(I learned this remarkable fact from the [oilshell blog](https://www.oilshell.org/blog/tags.html?tag=awk#awk) -- rather interesting technical blog, where author describes his progress in creating the "better bash").

The most substantial consequence is that it's forbidden to return an array from a function, you can return only a scalar value.

```awk
function f() {
   a[1] = 2
   return a # error
}

```
However, you can pass an array to a function and fill it there

```awk
BEGIN {
   fill(arr)
   print arr[0] " " arr[1]
}
function fill(arr,   i) { arr[i++] = "hello"; arr[i++] = "world" }
```

The thing is, in a lack of GC all heap allocations must be deterministic. That is, array, declared locally in a function must be destroyed at the moment when function returns. That's why it's disallowed to escape the declaration scope of a function (via return).

The absense of GC allows to keep the language implementation very simple, thus fast and portable. Also, with predictable memory consumption. To me, this qualifies AWK as perfect embeddable language, although, for some reason this niche is firmly occupied by (GC-equipped) Lua. 

## Local variables

All variables are global by default. However, if you add a variable to the function parameters (like `i` above) it becomes local. JavaScript works in a similar way, although there are more suitable `var`/`let`/`const` keywords. In practice, it is customary to separate "real" function parameters from "local" parameters with additional spaces for clarity.

Although Brian Kernighan (the K in AWK) regrets this design, in practice it works just fine.

> The notation for function locals is appalling (all my fault too, which makes it worse).
        

So it appears, the use of local variables is also a mechanism for automatic release of resources. Small [example](https://github.com/xonixx/gron.awk/blob/v0.2.0/gron.awk#L81):
```awk
function NUMBER(    res) {
  return (tryParse1("-", res) || 1) &&
    (tryParse1("0", res) || tryParse1("123456789", res) && (tryParseDigits(res)||1)) &&
    (tryParse1(".", res) ? tryParseDigits(res) : 1) &&
    (tryParse1("eE", res) ? (tryParse1("-+",res)||1) && tryParseDigits(res) : 1) &&
    asm("number") && asm(res[0])
}
```

The `NUMBER` function parses the number. `res` is a temporary array that will be automatically deallocated when the function exits.

## Autovivification

An associative array is declared simply by the fact of using the corresponding variable `arr` as an array.

```awk
arr["a"] = "b"
```

Likewise, a variable that is treated as a number (`i++`) will be implicitly declared as a numeric type, and so on.

To Perl connoisseurs, this feature may be known as [Autovivification](https://en.wikipedia.org/wiki/Autovivification). In general, AWK is quite unequivocally a prototype of Perl. You can even say that Perl is a kind of AWK overgrowth on steroids... However, we deviated.

This is done, obviously, in order to be able to write the most compact code in one-liners, for which many of us are used to using AWK.
        
## About AWK syntax/grammar

I want to tell about a couple of findings I encountered while implementing the parser for AWK for [intellij-awk](https://github.com/xonixx/intellij-awk) project.

### `$` is a unary operator

If you used AWK, most likely you've used `$0`, `$1`, `$2`, etc. Some even used `$NF`.

But did you know, that `$` is an operator, that can apply to an expression?

So it's perfectly valid to write

```awk
{ second=2; print $second }
```

or
```awk
{ print $ (1+1) }
```

or
```awk
{ i=1; print $++i }
```

With the same result as
```awk
{ print $2 }
```

Also, it's interesting to note, that `$` is the only operator that is allowed to appear on the left side of assignment, that is you can write

```awk
{ $(7-5) = "hello" }
```
or
```awk
{ $length("xx")="hello" }
```
(same as)
```awk
{ $2 = "hello" }
```

**Quiz.** What will be the output of
```shell
echo "2 3 4 hello" | awk '{ print $$$$1 }'
```

and why? Try to answer without running. Try adding even more `$`. Explain the behavior.

### function calling `f()` doesn't allow space before `(` ...

... but only for user-defined functions:

```shell
awk 'BEGIN { fff () } function fff(){ }' # syntax error
awk 'BEGIN { fff() }  function fff(){ }' # OK
```
You can have space for built-in functions:
```shell
awk 'BEGIN { print substr ("abc",1,2) }' # OK, outputs ab
```

Why such strange inconsistency? It's because of AWK's decision to use empty operator for strings concatenation

```awk
BEGIN { a = "hello"; b = "world"; c = a b; print c } # helloworld 
```

it means that AWK tries to parse `fff (123)` as concatenation of variable `fff` and string `123`.

Obviously `fff ()` is just a syntax error, the same as `fff (1,2)`.

As for built-in functions, AWK knows beforehand that it's not a variable name, so it can disambiguate.

### built-in functions are parsed as part of syntax

If you take a look at AWK specification at POSIX, at the [Grammar section](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/awk.html#tag_20_06_13_16) (yes, AWK grammar is a part of POSIX standard!), you'll notice that AWK functions are part of it. To be precise, they are parsed at _lexer_ step, so they enter _parser_ step as ready to use tokens.

The implication here is that you are disallowed to name your own function of variable with the name of any built-in function. It will be a syntax error!

```awk
BEGIN { length = 1 } # syntax error
```

Compare to python:
```python
len = 1 # OK
```

Why is this? For flexibility. Remember, AWK's main goal was to be extremely terse yet productive language well suited for one-liners. So:
- it's allowed to omit `()` for built-in functions, when no arguments passed, like in `echo "hello" | awk '{ print length }'` -- same as `echo "asda" | awk '{ print(length()) }'`
- same function can be used with different number of arguments, like `sub(/regex/, "replacement", target)` and `sub(/regex/, "replacement")` -- omitted `target` is implied as `$0`

All these nuances require pretty ad-hoc parsing for built-in functions. This is why they are part of grammar. If we take the `getline` keyword, it's not even a function, but rather a very versatile [syntax construct](https://www.gnu.org/software/gawk/manual/html_node/Getline.html).

### ERE vs DIV lexing ambiguity

AWK ad-hoc syntax, optimized for succinct code, has some [inherent ambiguities](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/awk.html#:~:text=There%20is%20a%20lexical%20ambiguity%20between%20the%20token) in its grammar.

The problem resides in lexing ambiguity of tokens ERE (extended regular expression, `/regex/`) vs DIV (`/`). Naturally, lexer prefers the longest matching term. This causes a problem for parsing a code like

```awk
a(1 / 2, 3 / 4)
```

Because it can parse as
```awk
a(1 (/ 2, 3 /) 4)
```

instead of correct
```awk
a((1/2), (3/4))
```

This kind of problems is well-known, and usually the implementation requires the [Lexer hack](https://en.wikipedia.org/wiki/Lexer_hack):

> The solution generally consists of feeding information from the semantic symbol table back into the lexer. That is, rather than functioning as a pure one-way pipeline from the lexer to the parser, there is a backchannel from semantic analysis back to the lexer. This mixing of parsing and semantic analysis is generally regarded as inelegant, which is why it is called a "hack".

In the original AWK (sometimes called the One True Awk), identifying regular expressions is the job of [the parser](https://github.com/onetrueawk/awk/blob/d62c43899fd25fdc4883a32857d0f157aa2b6324/awkgram.y#L289), which explicitly sets the lexer into "regex mode" when it has figured out that it should expect to read a regex:
```
reg_expr:
     '/' {startreg();} REGEXPR '/'     { $$ = $3; }
   ;
```
(`startreg()` is a function defined in [lex.c](https://github.com/onetrueawk/awk/blob/d62c43899fd25fdc4883a32857d0f157aa2b6324/lex.c#L515)) The `reg_expr` rule itself is only ever matched in contexts where a division operator would be invalid.

However, in intellij-awk I managed to disambiguate this on the Lexer level, but this required [creating a (somewhat sophisticated) lexer with multiple states](https://github.com/xonixx/intellij-awk/blob/main/src/main/java/intellij_awk/Awk.flex) (note the usage of state `DIV_POSSIBLE`).

---

You can check some other (Gawk-related) nuances I found in [parser_quirks.md](https://github.com/xonixx/intellij-awk/blob/main/doc/parser_quirks.md). 

---

Overall, I noticed that many _old_ programming languages have very ad-hoc syntax, and so parsing.

I think, partially, because they wanted to make the programming language very flexible (PL/1, Ada, C++, AWK, Perl, shell).

Partially, because some languages tried to be as close to human language as possible (SQL, or even COBOL -- almost every language feature in them is a separate syntax construct).

Or maybe because parsing theory wasn't that strong back then. So it was common to write ad-hoc parsers instead of using something like lex + yacc.

Nowadays, programming languages tend to have [much more regular syntax](https://softwareengineering.stackexchange.com/questions/316217/why-does-the-type-go-after-the-variable-name-in-modern-programming-languages). The most prominent example in this regard can be Go.
