---
layout: post
title: 'Fascination of AWK'
description: 'I describe why AWK is great for prototyping and is often the best alternative to the shell and Python'
image: makesure.png
---

# Fascination of AWK

_March 2023_

AWK is a delightful mini-language almost unchanged for decades.

A bare minimum of features includes strings, numbers, functions, associative arrays, line-by-line I/O and shell invocation. Perhaps, if it had fewer features, it would be impossible to program in it at all.

There is an opinion that AWK is not suitable for writing serious programs. Even Brian Kernighan (the K in AWK) is convinced that his language is only good for small one-liners. However, this does not prevent enthusiasts from creating rather voluminous programs in AWK:
- [Translate shell](https://github.com/soimort/translate-shell)
- [CHIP-8 emulator](https://github.com/patsie75/awk-chip8)
- [Git Graph Generator](https://github.com/deuill/grawkit)
- [Bibliography manager](https://github.com/huijunchen9260/bib.awk)
- [Simple yet powerful command runner](https://github.com/xonixx/makesure) (my creation)

The following experiments are also of interest:

- [Git Implementation](https://github.com/djanderson/aho)
- [Awklisp](https://github.com/darius/awklisp)
- [Awkprolog](https://github.com/prolog8/awkprolog)
- [Gron in Awk](https://github.com/xonixx/gron.awk) (my creation)

There is a simple explanation for this. A minimum of features liberates creativity. When there is only one way to do something, you don't spend a lot of time choosing that very way. You concentrate on implementing a pure idea. There is no temptation to add (often) unnecessary abstractions, simply because with such restrictions it is almost impossible to implement them. In addition, there is a sporting interest -- is it really possible to write something functional even in such a language?

Surprisingly, you can actually get very far with AWK most of the time. Many who tried said they were surprised how well the AWK prototype worked. So, there was not even much point in rewriting it into some more traditional programming language. I don't think this is an exception, but rather a consistent pattern, due to the true genius of the AWK authors.

> [I wrote a compiler in awk!](https://news.ycombinator.com/item?id=13452043)
>
> To bytecode; I wanted to use the awk-based compiler as the initial bootstrap stage for a self-hosted compiler. Disturbingly, it worked fine. Disappointingly, it was actually faster than the self-hosted version. But it's so not the right language to write compilers in. Not having actual datastructures was a problem. But it was a surprisingly clean 1.5kloc or so. awk's still my go-to language for tiny, one-shot programming and text processing tasks.


In principle, I am inclined to share this opinion. I am even ready to go as far as to say that what _can_ be scripted with AWK, _should_ be scripted with AWK (over Python, Ruby, Node.js, etc.). I'm not saying that you should write large applications, but for medium scripts, AWK is an absolutely fine alternative to mainstream scripting languages with many benefits. A good programmer chooses the most powerful tool for the job, the best programmer chooses the least powerful tool to do the job.

Personally, I've found that AWK is also a surprisingly good replacement for larger than average shell scripts.

## Why?

1. **Portability** (AWK is a [part of the POSIX standard](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/awk.html)). Probably, Python in this sense is [the most expressive opposite](https://xkcd.com/1987/). Shells are not a silver bullet either. Often, to be on the safe side you stick to POSIX shell instead of more feature-rich alternatives. However, if you take [this article](https://j3s.sh/thought/write-posix-shell.html), which promotes writing POSIX shell, you'll notice that all of its arguments apply equally or even better to AWK.  
2. Very **clean** C-like **syntax**
3. Powerful **associative arrays**
4. Powerful **string functions**
5. The language is very **minimalistic** and **non-redundant**
6. Easy **interoperability** with the shell. While the AWK core is very small, the full power of the standard *nix utilities is at your disposal.
7. The language is very **stable**. If you read the [canonical book on AWK, published back in 1988](https://ia903404.us.archive.org/0/items/pdfy-MgN0H1joIoDVoIC7/The_AWK_Programming_Language.pdf) (a masterpiece!), you can be sure that you know the whole language. It is unlikely that anyone would dare to say the same even about POSIX shell.

I also want to cite a programmer Vladimir Dinev, who also creates some interesting projects with AWK:

> ### [Why shell + awk?](https://github.com/vladcc/shawk#why-shell--awk)
>Mainly because of this serendipitous observation:
>
>The shell takes as input a string, executes one or more commands based on that string, and these commands output more strings as their result. awk is really good at working with strings. It can read them, write them, split them, compare them, match a regex, mostly anything you would want to do with a string. With the added bonus of doing math. The shell can call awk and awk can call the shell. The shell can execute any process, thus awk can execute any process. Therefore, awk can provide any input you can provide to the shell and make sense of any result. The shell and awk are best friends. With their help the Unix environment turns into this huge high level API. The equivalent of a function call is now running a process and all data gets a uniform representation - the string. Which is perfectly readable and writable by humans as well as by awk. Any script is now possible, all tedium begone!
>
>But wait - there's more. awk gives you the string, which can represent any scalar value. It also gives you the hash table, which can represent any object and data structure. It gives you a runtime stack, so you have recursion. It gives you pass by reference, so you can return more than a single value. So as long as your input and your output are text, any and all processing is possible. And what's made out of text? Source code. You got everything you need to read source, process source, and write source. And what can you do with that? Create a language, of course. And that language could as well be able to call the shell, which can call awk, which can call the shell, which...
>
>P.S. Also, bash and awk come with virtually any Unix environment, so that's pretty nice as well.

Now, with my [intellij-awk](https://github.com/xonixx/intellij-awk), which adds native AWK support to IntelliJ IDEA, it becomes justifiable to write even larger AWK scripts without much concern.

### Links

- [Why Learn AWK?](https://blog.jpalardy.com/posts/why-learn-awk/) -- great article by
  Jonathan Palardy conveying similar ideas
- [Python vs. awk](https://pmitev.github.io/to-awk-or-not/Python_vs_awk/) -- a remarkable case of replacing a 50 line Python script with 5 lines of AWK  
- [The AWK Programming Language](https://archive.org/download/pdfy-MgN0H1joIoDVoIC7/The_AWK_Programming_Language.pdf) -- the book by the AWK creators, a must-read!