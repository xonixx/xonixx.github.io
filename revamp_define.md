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

@goal release
  echo "Releasing version $VERSION..."
```

After adding [parameterized goals](parameterized_goals.md) feature it appeared that `@define` didn't always play well with the new feature. Notably, when you [defined a variable](https://github.com/xonixx/fhtagn/blob/f36d84f9593ed93b7f3b4704dbcd1daaa4c81992/Makesurefile#L5) there was [no way to reference it in a parameterized goal argument](https://github.com/xonixx/fhtagn/blob/f36d84f9593ed93b7f3b4704dbcd1daaa4c81992/Makesurefile#L70), so you needed copy-paste.

Another reason to rework / improve the `@define` was it's existing syntax 
```shell
@define VAR='value'
``` 
instead of more consistent (with the rest of makesure's directives) 
```shell
@define VAR 'value'
```
The former syntax was chosen in accordance with "worse is better" principle, because it was simpler to implement, because the implementation was roughly replacing `@define` by `export` and passing the resulting `export VAR='value'` into shell.   

So the [issue](https://github.com/xonixx/makesure/issues/139) was added. I spent some time [analyzing the implementation aspects](https://github.com/xonixx/makesure/blob/b14d141f42f3fe9f7e7872fe131af2b4f5891ca0/docs/revamp_define.md) for the change. 

## Re-implement CLI parsing

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



