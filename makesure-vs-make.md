---
layout: post
title: 'makesure vs make'
description: 'Pros and cons of Makesure over Make'
---

# makesure vs make

1. [Makesure](https://github.com/xonixx/makesure) is a _task runner_, make is a _build tool_.
2. Makesure has built-in targets listing via `-l` flag.
3. With makesure you don't need to escape `$` as `$$` in recipes.
4. With makesure you don't need to use tab-indentation in recipes.
5. Makesure runs the entire recipe in a single shell invocation, make runs each line of the recipe in a separate shell. You need [to use `\`-splitting](https://www.gnu.org/software/make/manual/html_node/Splitting-Recipe-Lines.html) to run recipe as a whole, or use GNU-make-specific [.ONESHELL](https://www.gnu.org/software/make/manual/html_node/One-Shell.html) special target.
6. Makesure has a built-in [timing](https://github.com/xonixx/makesure#options) capability (per-recipe and total).
7. There are [multiple flavors of make](https://mmap.page/dive-into/make/) slightly inconsistent in syntax/behavior. Makesure, being [zero-install](https://github.com/xonixx/makesure#installation), is by design more consistent. 
8. In Makesure all targets are _phony_ (in the sense of make). But you have explicit [@reached_if](https://github.com/xonixx/makesure#reached_if) directive to make the target declarative. 
9. Make has own turing-complete programming language (see [Lisp in make](https://github.com/kanaka/mal/tree/master/impls/make)). Makesure is just goals + dependencies + handful of directives + bash/shell.
10. Makesure, being a task runner, doesn't support parallel recipes execution, make supports via `-j` flag.
