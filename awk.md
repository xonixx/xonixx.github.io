---
title: 'Fascination of AWK (and some interesting facts)'
description: 'TODO'
image: TODO
---
[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://stand-with-ukraine.pp.ua)

# Fascination of AWK (and some interesting facts)

_March 2023_

## Why awk? -better shell

AWK - fascinating mini-language almost unchanged for decades. It is an interpreted language, very minimalistic.

A bare minimum of features includes strings, numbers, functions, associative arrays, line-by-line I/O and calling shell. Perhaps, we can say that it contains the minimum of features less than which it would be impossible to program on it at all.

There is an opinion that Awk is not suitable for writing serious programs. Even Brian Kernighan (the K in AWK) is convinced that his language is only good for small one-line programs. However, this does not prevent enthusiasts from creating rather voluminous programs in AWK:
- [Translate shell](https://github.com/soimort/translate-shell)
- [Compiler](https://news.ycombinator.com/item?id=13452043)
- [CHIP-8 emulator](https://github.com/patsie75/awk-chip8)
- [Simple yet powerful command runner](https://github.com/xonixx/makesure) (my creation)

The following experiments are also of interest:

- [Git Implementation](https://github.com/djanderson/aho)
- [Awklisp](https://github.com/darius/awklisp)
- [Awkprolog](https://github.com/prolog8/awkprolog)
- [Gron in Awk](https://github.com/xonixx/gron.awk) (my creation)

And there is a simple explanation for this. A minimum of features liberates creativity. When there is only one way to do something, you don't spend a lot of time choosing that very way, but you concentrate on implementing a pure idea. There is no temptation to add (often) unnecessary abstractions, simply because with such restrictions it is almost impossible to implement them. In addition, there is a sporting interest - is it really possible to write something functional even in such a language.

Surprisingly, you can actually get very far with AWK most of the time. Many who tried said they were surprised how well the AWK prototype worked. So, there was not even much point in rewriting it into some more traditional programming language.

> [I wrote a compiler in awk!](https://news.ycombinator.com/item?id=13452043)
>
> To bytecode; I wanted to use the awk-based compiler as the initial bootstrap stage for a self-hosted compiler. Disturbingly, it worked fine. Disappointingly, it was actually faster than the self-hosted version. But it's so not the right language to write compilers in. Not having actual datastructures was a problem. But it was a surprisingly clean 1.5kloc or so. awk's still my go-to language for tiny, one-shot programming and text processing tasks.


In principle, I am inclined to share this opinion. I am even ready to go as far as to say that what _can_ be scripted with AWK, _should_ be scripted with AWK (over Python, Ruby, Node.js, etc.). I'm not saying that you should write big apps though, but for small scripts AWK is absolutely fine alternative to major scripting languages with lots of benefits.Ordinary programmer tends to choose the most powerful tool for the job, hacker often prefers the least powerful tool for the job.

Personally, I've found AWK to be a surprisingly good replacement for larger than average shell scripts.

Why?

1. **Portability** (AWK - [part of the POSIX standard](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/awk.html)). Probably, Python in this sense will be [the most expressive opposite](https://xkcd.com/1987/). And there will also be a lot of shells themselves. Either the more functional, but less versatile bash/zsh, or the standard, but less rich in POSIX features, sh, or the cool, but non-standard fish.
2. Very **clean** C-like **syntax**
3. Powerful **associative arrays**
4. Powerful **string functions**
5. Easy **interoperability** with the shell. While the AWK core is very small, the full power of the standard *nix utilities is at your disposal.
6. The language is very **minimalistic** and non-redundant, not changing since probably the year 1985. Therefore, even after reading the [canonical book](https://ia903404.us.archive.org/0/items/pdfy-MgN0H1joIoDVoIC7/The_AWK_Programming_Language.pdf ), you can be sure that you know the whole language. It is unlikely that anyone would dare to say such a thing even about POSIX sh.

So, if you take [this article](https://j3s.sh/thought/write-posix-shell.html) that promotes writing POSIX shell, you'll notice that all of it arguments apply to AWK equal or even better.

I also want to cite a programmer [Vladimir Dinev](https://github.com/vladcc), who is creating some interesting projects with AWK:

> ### [Why shell + awk?](https://github.com/vladcc/shawk#why-shell--awk)
>Mainly because of this serendipitous observation:
>
>The shell takes as input a string, executes one or more commands based on that string, and these commands output more strings as their result. awk is really good at working with strings. It can read them, write them, split them, compare them, match a regex, mostly anything you would want to do with a string. With the added bonus of doing math. The shell can call awk and awk can call the shell. The shell can execute any process, thus awk can execute any process. Therefore awk can provide any input you can provide to the shell and make sense of any result. The shell and awk are best friends. With their help the Unix environment turns into this huge high level API. The equivalent of a function call is now running a process and all data gets an uniform representation - the string. Which is perfectly readable and writable by humans as well as by awk. Any script is now possible, all tedium begone!
>
>But wait - there's more. awk gives you the string, which can represent any scalar value. It also gives you the hash table, which can represent any object and data structure. It gives you a runtime stack, so you have recursion. It gives you pass by reference, so you can return more than a single value. So as long as your input and your output are text, any and all processing is possible. And what's made out of text? Source code. You got everything you need to read source, process source, and write source. And what can you do with that? Create a language, of course. And that language could as well be able to call the shell, which can call awk, which can call the shell, which...
>
>P.S. Also, bash and awk come with virtually any Unix environment, so that's pretty nice as well.

Now, with [native AWK support](https://github.com/xonixx/intellij-awk) in IntelliJ IDEA it really becomes justified to write bigger AWK scripts without much fear.    

> This plugin adds to IntelliJ IDEA the native support for AWK programming language. Once installed, you'll be able to have syntax highlighted in your *.awk files as well as other usual code editing functionalities like variables/functions renaming, code completion, go to declaration, find usages, auto-formatting and more.

## Interesting facts of AWK: no GC, etc.

Surprisingly, the AWK language does not require a GC for its implementation. Same as sh/bash. 

The secret here is that the language, roughly speaking, simply lacks the ability to do 'new', that is dynamically allocate objects on heap. For example, an associative array is declared simply by the fact of using the corresponding variable as an array.

```awk
arr["a"] = "b"
```

To Perl connoisseurs, this feature may be known as [Autovivification](https://en.wikipedia.org/wiki/Autovivification). In general, AWK is quite unequivocally a prototype of Perl. You can even say that Perl is a kind of AWK overgrowth on steroids ... However, we deviated.

Likewise, a variable that is treated as a number (`i++`) will be implicitly declared as a numeric type, and so on.
This is done, obviously, in order to be able to write the most compact code in one-liners, for which many of us are used to using AWK.

It is also forbidden to return an array from a function, only a scalar value is allowed.

```awk
function f() {
   a[1] = 2
   return a # error
}

```
But, you can pass an array to a function and fill it there

```awk
BEGIN {
   fill(arr)
   print arr[0] " " arr[1]
}
function fill(arr,   i) { arr[i++] = "hello"; arr[i++] = "world" }
```

Another interesting feature. All variables are global by default. However, if you add a variable to the function parameters (like `i` above) it becomes local. Javascript works in a similar way, although there are more suitable `var`/`let`/`const`. In practice, it is customary to separate "real" function parameters from "local" parameters with additional spaces for clarity.

Actually, the use of local variables is a mechanism for automatic release of resources. Small [example](https://github.com/xonixx/gron.awk/blob/main/gron.awk#L81).
```awk
function NUMBER(    res) {
  return (tryParse1("-", res) || 1) &&
    (tryParse1("0", res) || tryParse1("123456789", res) && (tryParseDigits(res)||1)) &&
    (tryParse1(".", res) ? tryParseDigits(res) : 1) &&
    (tryParse1("eE", res) ? (tryParse1("-+",res)||1) && tryParseDigits(res) : 1) &&
    asm("number") && asm(res[0])
}
```

The `NUMBER` function parses the number. `res` is a temporary array that will be removed automatically when the function exits.


More of the interesting.

```
$ node -e 'function sum(n) { return n == 0 ? 0 : n + sum(n-1) }; console.info(sum(100000))'
[eval]:1
function sum(n) { return n == 0 ? 0 : n + sum(n-1) }; console.info(sum(100000))
                   ^

RangeError: Maximum call stack size exceeded
     atsum([eval]:1:19)
     atsum([eval]:1:43)
     atsum([eval]:1:43)
     atsum([eval]:1:43)
     atsum([eval]:1:43)
     atsum([eval]:1:43)
     atsum([eval]:1:43)
     atsum([eval]:1:43)
     atsum([eval]:1:43)
     atsum([eval]:1:43)
```

The same Gawk will chew a million and not choke:

```
$ gawk 'function sum(n) { return n == 0 ? 0 : n + sum(n-1) }; BEGIN { print sum(1000000) }'
500000500000
```

By the way, GAWK [supports](https://blog.0branch.com/posts/2016-05-13-awk-tco.html) tail optimization.

---

## About AWK syntax/grammar.

I want to tell about a couple of findings I encountered while implementing the parser for AWK for [intellij-awk](https://github.com/xonixx/intellij-awk) project. 

https://github.com/xonixx/intellij-awk/blob/main/doc/parser_quirks.md

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

Overall, I noticed that many _old_ programming languages have very ad-hoc syntax, and so parsing.

I think, partially, because they wanted to make the programming language very flexible (PL/1, Ada, C, AWK, shell)

Partially, because some languages tried to be as close to human language as possible (SQL, or even COBOL -- almost every language feature in them is a separate syntax construct).

Maybe, because parsing theory was not that strong yet. So it was common to write ad-hoc parsers instead of using something like lex + yacc.

Nowadays programming languages tend to have much more regular syntax, and so grammar. The most prominent example in this regard can be Go. 


### ERE vs DIV lexing ambiguity
                       
AWK ad-hoc syntax, optimized for succinct code, has some [inherent ambiguities](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/awk.html#:~:text=There%20is%20a%20lexical%20ambiguity%20between%20the%20token) in its grammar.

The problem resides in lexing ambiguity of tokens ERE (extended regular expression, `/regex/`) vs DIV (`/`). Naturally, lexer prefers the longer term. This causes a problem for parsing a code like

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

However, in intellij-awk I managed to disambiguate this on the Lexer level, but this required [creating a lexer with multiple states](https://github.com/xonixx/intellij-awk/blob/main/src/main/java/intellij_awk/Awk.flex) (note the usage of state `DIV_POSSIBLE`).

### Links

- [The state of the AWK](https://lwn.net/Articles/820829/)
- [Awk in 20 Minutes](https://ferd.ca/awk-in-20-minutes.html) - refresher on the basics of AWK
- [Why Learn AWK?](https://blog.jpalardy.com/posts/why-learn-awk/)
- https://github.com/freznicek/awesome-awk
- https://www.libhunt.com/topic/awk
- https://github.com/patsie75
- https://pmitev.github.io/to-awk-or-not/Python_vs_awk/
- https://www.oilshell.org/blog/tags.html?tag=awk#awk

### TODO

Canonical and very fascinating [book](https://ia903404.us.archive.org/0/items/pdfy-MgN0H1joIoDVoIC7/The_AWK_Programming_Language.pdf) authored by the entire trio of A, W and K creators, which came out back in 1988, but it has not completely lost its relevance.

> Read The AWK Programming Language, a joy to read, one of the finest docs ever written, I reckon.

I learned this remarkable fact from the [oilshell blog](https://www.oilshell.org/blog/tags.html?tag=awk#awk) (by the way, rather interesting technical blog, where author describes his progress in creating the "better bash").