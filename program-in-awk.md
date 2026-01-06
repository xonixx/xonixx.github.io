---
layout: post
title: 'How I program in AWK'
description: 'I describe what, how and why I program in AWK'
image: program-in-awk.png
---

# How I program in AWK

_January 2026_

**What is AWK?** 

AWK is a CLI utility (and a programming language), targeted at text processing, present in every Unix-like OS.

**What do you program in AWK?** 

[Makesure](https://github.com/xonixx/makesure) – a task runner that is somewhat similar to `make`, but
[without most of its idiosyncrasies](makesure-vs-make.md) (and with a couple of unique features!).
    
**Wait, but AWK is intended only for one-liners... How come do you program a whole project in it?**

Indeed, the language is really minimalistic, but it has just enough to fulfill certain kinds of projects.

**Are you mad?**

Who knows...

**But what are the motivators?**

[Tremendous portability and fun](awk.md)

**But AWK doesn't have good IDE support for big-ish projects...**

This was indeed the case. And this motivated me to create an [AWK language support plugin for IntelliJ IDEA](https://github.com/xonixx/intellij-awk). 

Now if you consider that using AWK for developing Makesure makes little sense, you still must admit that a byproduct result of the
AWK IDEA plugin is already a good justification 😊.

Btw, you can read about [one of my adventures in creating this plugin](intellij-awk_grammar_refactoring.md).

**Did you create any other tools to make your AWK programming easier?**

Sure:

- [fhtagn](fhtagn.md) – a tiny CLI tool for literate testing for command-line programs. I test Makesure with it.
- [AWK code coverage support in GoAWK](goawk_cover.md) – I calculate test coverage for Makesure with it.
- [mdBooker](mdbooker.md) – it helps me to generate a Makesure documentation site [makesure.dev](https://makesure.dev) from the project's README.

**Do you eat your own dog food?**

Absolutely, see the tools above.

In addition, I [use](https://github.com/xonixx/makesure/blob/main/Makesurefile) Makesure to develop Makesure.

Clearly, I develop Makesure in intellij-awk. I also [use](https://github.com/xonixx/intellij-awk/blob/main/Makesurefile) Makesure to develop intellij-awk itself.

I [use](https://github.com/xonixx/fhtagn/blob/main/Makesurefile) Makesure to develop fhtagn.

And so on.

**Any other practice you use?**
                           
I use [awk_lab](https://github.com/xonixx/awk_lab) repo as a playground for my AWK experiments. A byproduct of such experiments was [my re-implementation of gron in AWK](https://github.com/xonixx/gron.awk).

**It looks like you are having lots of fun with AWK**
 
Indeed! Find my [Bytebeating story](bytebeat_gawk.md). Also check my [cellular automata experiment](https://github.com/xonixx/cellulawk).

**Can you tell me more interesting facts about AWK?**

You might find entertaining my [AWK technical notes](awk_tech_notes.md).
