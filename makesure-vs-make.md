
# makesure vs make

1. Makesure is a _task runner_, make is a _build tool_.
2. Makesure has built-in targets listing via `./makesure -l`
3. You don't need to escape `$` as `$$` in recipes.
4. Makesure is multiline by default, make runs each recipe line in separate shell. You need [to use `\`-splitting](https://www.gnu.org/software/make/manual/html_node/Splitting-Recipe-Lines.html) to run recipe as a whole.
5. Makesure has built-in [timing](https://github.com/xonixx/makesure#options) capability (per-recipe and total).
6. There are [multiple flavors of make](https://mmap.page/dive-into/make/) slightly inconsistent in syntax/behavior. Makesure, being [zero-install](https://github.com/xonixx/makesure#installation), is by design more consistent. 
7. In Makesure all targets are _phony_ (in the sense of make). But you have explicit [@reached_if](https://github.com/xonixx/makesure#reached_if) directive to make a target declarative. 
8. Makesure, being task runner, doesn't support parallel recipes execution, make supports via `-j` flag.
9. Make has own turing-complete programming language (see [Lisp in make](https://github.com/kanaka/mal/tree/master/impls/make)). Makesure is just goals + dependencies + handful of directives + bash/shell.