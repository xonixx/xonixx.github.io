---
layout: post
title: 'TODO'
description: 'TODO'
image: TODO.png
---

# Release v0.9.21 / Revamp define

_TODO 2023_

## Makesure

[Makesure](https://github.com/xonixx/makesure) is a task/command runner that
I am developing. It is somewhat similar to the well-known `make` tool, but
[without most of its idiosyncrasies](makesure-vs-make.md) (and with a couple of unique features!).

## Why revamping define?

Makesure had `@define` directive that looked like:

```shell
@define VERSION='3.12'

@goal released
  echo "Releasing version $VERSION..."
```
   
### Reason #1

After adding [parameterized goals](parameterized_goals.md) feature it appeared that `@define` didn't always play well with the new feature. Notably, when you [defined a variable](https://github.com/xonixx/fhtagn/blob/f36d84f9593ed93b7f3b4704dbcd1daaa4c81992/Makesurefile#L5) there was no way to reference it in a parameterized goal argument, so you [needed copy-paste](https://github.com/xonixx/fhtagn/blob/f36d84f9593ed93b7f3b4704dbcd1daaa4c81992/Makesurefile#L70). We needed this instead:

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
The former syntax was chosen in accordance with "worse is better" principle: it was simpler to implement, because the implementation was roughly replacing `@define` by `export` and passing the resulting `export VAR='value'` into shell. Operationally, when `./makesure released` called, the shell script below was executed under the hood:

```shell
export VERSION='3.12'
echo "Releasing version $VERSION..."
```

So the [issue](https://github.com/xonixx/makesure/issues/139) was added. I spent some time [analyzing the implementation aspects](https://github.com/xonixx/makesure/blob/b14d141f42f3fe9f7e7872fe131af2b4f5891ca0/docs/revamp_define.md) for the change. 

## Re-implement CLI parsing

The design of the `@define` directive was well described in my past [article](makesure.md#designing-define).

I want to quote a piece from it:

> We have a dilemma. Either we refuse to pass to the shell and add an ad-hoc parser for this directive, or we have what we have.
>
> A custom parser would be a good option if it weren’t for the extreme complexity that needs to be added.

So it became apparent that to fulfill both reasons (but, especially, Reason #1) above the existing execution model was not enough. The ad-hoc line parsing was needed that replicates the parsing of shell. Why is so?

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

And this is exactly [what was done](https://github.com/xonixx/awk_lab/blob/458f9f7/parse_cli_2_lib.awk).

## How it was tested

### Mglwnafh

### Checking against bash

## How we test samples in README for correctness

## How we improved minifying

[22.3 KB](https://github.com/xonixx/makesure/blob/v0.9.20/makesure) -> [22 KB](https://github.com/xonixx/makesure/blob/v0.9.21/makesure)

## Spaces in `@define` and `@reached_if` bug

## Approach to more strict parsing

https://github.com/xonixx/makesure/blob/main/docs/revamp_define.md#q-how-do-we-know-when-to-parse-with----quoted-strings-or-unquoted

https://github.com/xonixx/makesure/issues/141



