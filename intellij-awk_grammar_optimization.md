---
layout: post
title: 'TODO'
description: 'TODO'
image: TODO
---

# How I accidentally optimized the parsing in IntelliJ-AWK

_TODO 2023_

### TL;DR

[IntelliJ-AWK](https://github.com/xonixx/intellij-awk) is a language support plugin for AWK that I develop for the IntelliJ IDEA.

***

The story started with this [issue](https://github.com/xonixx/intellij-awk/issues/133). The autocomplete was not working in the presence of not-closed `if`:

![](https://user-images.githubusercontent.com/11706893/195204634-38068080-2748-4e8e-8679-9bc418242fc3.png)
                           
This is because in the presence of incomplete code the AST (abstract syntax tree) for a program can be incomplete or broken.

### Why so?

Let's elaborate a bit. Autocompletion in IDE works by querying the nodes of the AST representation of a source code that is built by IDE behind the scene. To help you get the idea, the AST is conceptually similar to the DOM in HTML. It's a tree-like structure that represents a parsed form of a program code. So, for example, to autocomplete the function names we need to traverse the AST tree and find all nodes of type `"function"`.

