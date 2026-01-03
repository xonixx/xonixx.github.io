---
layout: post
title: 'TODO'
description: 'TODO'
image: TODO
---

# How I program in AWK

_January 2026_

**What do I program in AWK?** 

[Makesure](https://github.com/xonixx/makesure) – a task/command runner that is somewhat similar to the well-known `make` tool, but
[without most of its idiosyncrasies](makesure-vs-make.md) (and with a couple of unique features!).
    
**Wait, but AWK is intended only for one-liners... How come do I program a whole project in it?**

Indeed, the language is really minimalistic, but it has just enough to fulfill certain kinds of projects.

**But what are the motivators?**

[Tremendous portability and fun](awk.md)

**Am I mad?**

Who knows...

**But AWK doesn't have good enough IDE support for big-ish projects...**

This was indeed the case. And this motivated me to create an [AWK language support plugin for IntelliJ IDEA](https://github.com/xonixx/intellij-awk). 

Now if you consider that using AWK for developing Makesure makes little sense, you still must admit that a byproduct result of the
AWK IDEA plugin is already a good justification 😊

Btw, you can read about [one of my adventures in creating this plugin](intellij-awk_grammar_refactoring.md).

**Did I create any other tools to make my AWK programming easier?**

Sure:

- [fhtagn](fhtagn.md) – a tiny CLI tool for literate testing for command-line programs. I test Makesure with it.
- [AWK code coverage support in GoAWK](goawk_cover.md) – I calculate test coverage for Makesure with it.
- [mdBooker](mdbooker.md) – it helps me to generate a Makesure documentation site [makesure.dev](https://makesure.dev).

**Do I eat my own dog food?**

Absolutely, see the tools above.

In addition, I [use](https://github.com/xonixx/makesure/blob/main/Makesurefile) Makesure to develop Makesure.

I also [use](https://github.com/xonixx/intellij-awk/blob/main/Makesurefile) Makesure to develop intellij-awk.

I [use](https://github.com/xonixx/fhtagn/blob/main/Makesurefile) Makesure to develop fhtagn.

And so on.

