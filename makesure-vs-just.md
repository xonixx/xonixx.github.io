---
layout: post
title: 'makesure vs just on examples'
description: 'This article compares the two tools on some particular real-world examples'
---

# `makesure` vs `just` on examples

- [Makesure](https://github.com/xonixx/makesure) is a task/command runner that
I am developing. It is somewhat similar to the well-known `make` tool, but
[without most of its idiosyncrasies](makesure-vs-make.md) (and with a couple of unique features!).

- [just](https://github.com/casey/just) is a very popular alternative command runner that positions itself as "a handy way to save and run project-specific commands".

This article compares the two tools on some particular real-world examples.

## #1 Defining dependent vars 

[Problem](https://github.com/casey/just/issues/1292)

Makesure was deliberately designed to **not** have its own programming language. In essence, it consists of goals + dependencies + handful of directives + shell. So it doesn't have two types of variables and therefore has an idiomatic solution:

```shell
@lib
  GIT_COMMIT="$(git rev-parse --short HEAD)"
  GIT_TIME="$(git show -s --format=%ci $GIT_COMMIT | tr -d '\n')"

@goal default
@use_lib
  echo "$GIT_COMMIT"
  echo "$GIT_TIME"
```

## #2 Comments in recipes are echoed

[Problem](https://github.com/casey/just/issues/1274)

Makesure doesn't echo script lines by default. Command runner (as opposed to a build tool, like `make`) is recipe-oriented, not line-oriented. The unit of work is a recipe, not a line. So the recipe body is just an implementation detail.

However, it logs the goal names being executed, such that it's clear what's going on:

```
$ ./makesure
  goal 'fhtagn_installed' [already satisfied].
  goal 'debug' ...
GNU Awk 5.0.1, API: 2.0 (GNU MPFR 4.0.2, GNU MP 6.2.0)
GNU bash, version 5.0.17(1)-release (x86_64-pc-linux-gnu)
  goal 'debug' took 0.006 s
  goal 'prepared4tests' [empty].
  goal 'tests.basic.tush' ...
TESTS PASSED : tests.basic.tush
  goal 'tests.basic.tush' took 0.273 s
  goal '*.tush' [empty].
  goal 'tested' [empty].
  goal 'default' [empty].
  total time 0.281 s
```

Though, if you need, Makesure also has `-x` option with the same function as in shell (activates command tracing).

## #3 Distinction between doc and non-doc comments

[Problem](https://github.com/casey/just/issues/1273)

Makesure doesn't have such issue because it uses a special directive `@doc` for a goal description, which doesn't interfere with regular comments:

```shell
# some regular comment
@goal do_it
# some other comment
@doc 'This is very useful goal'
  echo 'Doing...'
```

Overall Makesure chose an approach with a uniform syntax via [directives](https://github.com/xonixx/makesure#directives) rather than an ad-hoc syntax for every feature. This proved to be very solid choice for many reasons:
- uniformity
- ease of searching for the documentation
- free Makesure file syntax highlighting! Surprisingly, Makesurefile's [syntax is a valid shell syntax](https://github.com/xonixx/makesure/blob/aa4a32eae6178fd0c6a7f14e2f46142e099a8f97/Makesurefile).

## #4 Need to install

[Problem](https://github.com/casey/just/issues/429#issuecomment-1332682438)

Makesure [doesn't need installation](https://github.com/xonixx/makesure#installation)

## #5 Files as dependency

[Problem](https://github.com/casey/just/issues/867)

[How you do it with makesure](https://github.com/casey/just/issues/867#issuecomment-1344887900)

## #6 Default target doesn't play well with `!include`

[Problem](https://github.com/casey/just/issues/1557)

By default, `just` invokes the first recipe. Makesure by default invokes the goal named `default`. So, although makesure doesn't have includes, if it had, the issue would not happen.

## #7 `just` can fail to execute shebang-recipes due to 'Permission denied'

[Problem](https://github.com/casey/just/issues/1611)
                                                                         
Makesure doesn't produce temp files during goal execution, so it's not susceptible to this problem.

## #8 Need for custom functions for string manipulation

[Problem](...)
  
Makesure uses shell (instead of own programming language) and relies on shell variables (instead of own kind of variables).

The idiomatic solution to the described problem using [parameterized goals](https://maximullaris.com/parameterized_goals.html):

```shell
@define BUILD_DIR 'build'
@define FILE_NAME 'out'

@goal pandoc @params ARG EXT @private
    echo pandoc input.md -o "$BUILD_DIR/$ARG/$FILE_NAME.$EXT"

@goal html @params ARG
@depends_on pandoc @args ARG 'html'

@goal pdf @params ARG
@depends_on pandoc @args ARG 'pdf'

@goal foo
@depends_on html @args 'foo'
@depends_on pdf  @args 'foo'
```

Calling:
```
$ ./makesure -l
Available goals:
  foo
  html@foo
  pdf@foo

$ ./makesure foo
  goal 'pandoc@foo@html' ...
pandoc input.md -o build/foo/out.html
  goal 'html@foo' [empty].
  goal 'pandoc@foo@pdf' ...
pandoc input.md -o build/foo/out.pdf
  goal 'pdf@foo' [empty].
  goal 'foo' [empty].

$ ./makesure html@foo
  goal 'pandoc@foo@html' ...
pandoc input.md -o build/foo/out.html
  goal 'html@foo' [empty].

```

## #9 Lack of incremental changes support

Such support could avoid unnecessary re-runs.

[Problem](https://github.com/casey/just/issues/424)

[Idempotence](https://arslan.io/2019/07/03/how-to-write-idempotent-bash-scripts/) is achievable elegantly with Makesure using [@reached_if](https://github.com/xonixx/makesure#reached_if) directive.

## Conclusion

It's clear that as an author of the tool I'm completely biased. 

But to me the minimalism and inherent simplicity and coherence allows Makesure to
- eliminate having some problems
- solve many problems more elegantly   
