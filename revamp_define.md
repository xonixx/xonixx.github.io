---
layout: post
title: "makesure v0.9.21 -- what's new?"
description: 'I describe the improvements in makesure v0.9.21. The main theme of this release is revamping the @define directive.'
image: parameterized_goals2.png
---

# makesure v0.9.21 -- what's new?

_TODO 2023_

[Makesure](https://github.com/xonixx/makesure) is a task/command runner that
I am developing. It is somewhat similar to the well-known `make` tool, but
[without most of its idiosyncrasies](makesure-vs-make.md) (and with a couple of unique features!).

---

The main theme of [this release](https://github.com/xonixx/makesure/milestone/15?closed=1) was [revamping](https://github.com/xonixx/makesure/issues/140) the `@define` directive.

Makesure's `@define` directive looked like:

```shell
@define VERSION='3.12'

@goal released
  echo "Releasing version $VERSION..."
```

Why did we want to change it and how?
   
### Reason #1

After adding [parameterized goals](parameterized_goals.md) feature it appeared that `@define` didn't always play well with the new feature. Notably, when you [defined a variable](https://github.com/xonixx/fhtagn/blob/f36d84f9593ed93b7f3b4704dbcd1daaa4c81992/Makesurefile#L5) there was no way to reference it in a parameterized goal argument, so you [needed copy-paste](https://github.com/xonixx/fhtagn/blob/f36d84f9593ed93b7f3b4704dbcd1daaa4c81992/Makesurefile#L70-L71). We needed this instead:

```shell
@define GOAWK_VERSION '1.24.0'
@define GOAWK         "./soft/goawk$GOAWK_VERSION"

@goal tested_by_goawk
@depends_on installed_goawk
@depends_on tested_by @args 'tush'   "$GOAWK -f ./fhtagn.awk"
@depends_on tested_by @args 'fhtagn' "$GOAWK -f ./fhtagn.awk"
```
   
### Reason #2

Another reason to rework the `@define` was it's existing syntax: 
```shell
@define VAR='value'
``` 
instead of more consistent (with the rest of makesure's directives): 
```shell
@define VAR 'value'
```
The former syntax was chosen in accordance with ["worse is better"](https://www.dreamsongs.com/RiseOfWorseIsBetter.html) principle: it was simpler to implement, because the implementation was roughly replacing `@define` by `export` and passing the resulting `export VAR='value'` into shell. Operationally, when `./makesure released` was called, the shell script below was executed under the hood:

```shell
export VERSION='3.12'
echo "Releasing version $VERSION..."
```

I drafted the described changes in a [separate document](https://github.com/xonixx/makesure/blob/9fd7fda8518d90aa6494cc0dd5ed19926dd8befb/docs/revamp_define.md) in order to come up with the good implementation strategy.

## Re-implement CLI parsing

The design of the `@define` directive was well described in my past [article](makesure.md#designing-define).

I want to quote a piece from it:

> We have a dilemma. Either we refuse to pass to the shell and add an ad-hoc parser for this directive, or we have what we have.
>
> A custom parser would be a good option if it weren’t for the extreme complexity that needs to be added.

So it became apparent that to fulfill both reasons above (but, especially, **Reason #1**) the existing execution model was not enough. The ad-hoc line parsing was needed that replicates the parsing of shell. Why is so?

The execution model of makesure consists roughly of two steps:

1. Resolving a dependency tree (including dependency loops detection, parameterized goals monomorphization, etc.)
2. Executing goal bodies (as shell scripts) in proper order.

The existing execution model worked when the `@define`-d variables were only referenced inside goal bodies, so needed only in step 2. 
Now, we need to know each variable value at step 1.

This means, we literally need to implement the parsing and interpretation of the code below without resorting to actual shell invocation:

```shell
@define HELLO 'Hello'
@define WORLD 'world'
@defile HW    "$HELLO ${WORLD}!"
```

The [implemented parser](https://github.com/xonixx/awk_lab/blob/458f9f7/parse_cli_2_lib.awk) appears to be not so complex, mostly because intentionally it doesn't cover all possible shell-compatible syntax, but rather a sufficient subset of it.

## How it was implemented and tested

The idea of using [AWK](awk.md) for Makesure is the ease of parsing. For example, this Makesure syntax is fairly easy parseable with AWK:

```
@goal built
@depends_on tested
    gcc code.c 
```

AWK already does word-splitting for you, so all you need is this:

```awk
if      ($1 == "@goal")       handleGoal($2)
else if ($1 == "@depends_on") handleDependency($2)
else                          handleCodeLine($0)
```

This approach is built on the fact that by default AWK tokenizes each input line to fields. It does so by splitting by whitespaces:

```
$ echo ' @depends_on  dep1    dep2  ' | awk '{ printf "$1=%s\n$2=%s\n$3=%s\n", $1, $2, $3 }'
$1=@depends_on
$2=dep1
$3=dep2
```

However, this breaks miserably if you want the tokenization to be shell-compatible:

```
$ echo " aaa   \"bb bbb\"   'cc c   c'  " | awk '{ printf "$1=%s\n$2=%s\n$3=%s\n", $1, $2, $3 }'
$1=aaa
$2="bb
$3=bbb"
```

instead of desirable:
```
$1=aaa
$2=bb bbb
$3=cc c   c
```

### Re-parsing CLI

To solve this problem we need to reparse the line to "patch" the way of how AWK parses it, making the tokenization shell-compatible. This is the idea behind [reparseCli](https://github.com/xonixx/makesure/blob/v0.9.21/makesure.awk#L887) function.

I developed the actual function [parseCli_2](https://github.com/xonixx/awk_lab/blob/458f9f7/parse_cli_2_lib.awk) in a separate repository [awk_lab](https://github.com/xonixx/awk_lab) which is a playground for my AWK-related experiments.

This way I can develop and test separate pieces for the main software (Makesure) in isolation, which is very convenient.

In particular, I want to show you the way I tested this function, using [literate testing](https://arrenbrecht.ch/testing/) approach. 

All test cases are compiled in a single [text file](https://github.com/xonixx/awk_lab/blob/458f9f7/parse_cli_2.txt). 

Each test is represented by the input, like:
```
=================
| $'aaa'\t  $'bbb ccc'    # comment |
```

And the expected output:
```
-----------------
0:$: aaa
1:$: bbb ccc
```

or (if parse error is expected):
```
-----------------
error: unterminated argument
```

Then, I have a small ["test runner"](https://github.com/xonixx/awk_lab/blob/458f9f7/parse_cli_N_test.awk) that interprets and runs the text file with a test suite above.

The execution model is quite remarkable. The test runner only interprets the test input lines (starting with `|`). Then, it just copies all the input lines as is, but produces the actual test outputs. Eventually, if all tests pass the result output file matches the input one. 

This is why to check the result we use `diff` to compare the test suite file content with the test output file content [(link)](https://github.com/xonixx/awk_lab/blob/458f9f7/parse_cli_2.tush). The `diff` output (if present) also helps to understand the failing tests.

This approach also helps to have other parsing implementations side-by-side ([parseCli](https://github.com/xonixx/awk_lab/blob/458f9f7cec12352d3a56b7dbf668bd247dbacf7c/parse_cli_0_lib.awk), [parseCli_1](https://github.com/xonixx/awk_lab/blob/458f9f7cec12352d3a56b7dbf668bd247dbacf7c/parse_cli_1_lib.awk)) and tests for them in the same format ([parse_cli_0.txt](https://github.com/xonixx/awk_lab/blob/458f9f7cec12352d3a56b7dbf668bd247dbacf7c/parse_cli_0.txt), [parse_cli_1.txt](https://github.com/xonixx/awk_lab/blob/458f9f7cec12352d3a56b7dbf668bd247dbacf7c/parse_cli_1.txt)).

It's worth mentioning that this approach to testing is very similar to the ideas in [fhtagn](fhtagn.md).

### Checking against bash

To guarantee that our parsing is consistent with bash the positive parse results [are cross-checked](https://github.com/xonixx/awk_lab/blob/458f9f7cec12352d3a56b7dbf668bd247dbacf7c/parse_cli_N_test.awk#L27) against bash parsing. 

### Mglwnafh

A by-product of this development was a tiny script [mglwn.awk](https://github.com/xonixx/awk_lab/blob/458f9f7cec12352d3a56b7dbf668bd247dbacf7c/mglwnafh/mglwn.awk) that contains very simple includes implementation for AWK.

The idea is simple. You define the included dependencies inline in your AWK script, as a comment. Let's say we have a file `main.awk`:

```awk
#include lib.awk
BEGIN { libFunction() }
```

So now, invoking `./mglwn.awk main.awk` will run `awk -f lib.awk -f main.awk`.

This mechanism allows to implement some very basic form of [inheritance / abstract functions in AWK](https://github.com/xonixx/awk_lab/blob/458f9f7cec12352d3a56b7dbf668bd247dbacf7c/parse_cli_2_test.awk)! 🤯

By the way, this use-case allowed to identify and fix [this problem](https://github.com/xonixx/intellij-awk/issues/203) in intellij-awk project.

## How we test samples in README for correctness

A [script](https://github.com/xonixx/makesure/blob/6f35ec956931bf49b9e490d864fb24ac9ae51cc7/check_samples_in_README.awk) was added as a part of the release, that checks the validity of Makesure samples in project's [README.md](https://github.com/xonixx/makesure/blob/6f35ec956931bf49b9e490d864fb24ac9ae51cc7/README.md).

## How we improved minifying
       
A script [minify.awk](https://github.com/xonixx/makesure/blob/6f35ec956931bf49b9e490d864fb24ac9ae51cc7/minify.awk) is a part of the project. It's used to compile the final executable file [makesure](https://github.com/xonixx/makesure/blob/6f35ec956931bf49b9e490d864fb24ac9ae51cc7/makesure) out of the source file [makesure.awk](https://github.com/xonixx/makesure/blob/6f35ec956931bf49b9e490d864fb24ac9ae51cc7/makesure.awk).

This script received some improvements in this release. 

The result of this effort was that despite the added functionality, the size of the executable decreased:
        
| v0.9.20                                                             | v0.9.21                                                           |
|---------------------------------------------------------------------|-------------------------------------------------------------------|
| [22.3 KB](https://github.com/xonixx/makesure/blob/v0.9.20/makesure) | [22 KB](https://github.com/xonixx/makesure/blob/v0.9.21/makesure) |

---

So let's summarize. We redesigned a feature by making it more functional and consistent without the increase in final program size.

If you are interested, I invite you to try out the [makesure](https://github.com/xonixx/makesure) utility in your projects.
The more so as it doesn't require installation [(how is that?)](https://github.com/xonixx/makesure#installation) and is [very portable](https://github.com/xonixx/makesure#os).


