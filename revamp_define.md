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

After adding [parameterized goals](parameterized_goals.md) to Makesure it appeared that `@define` didn't always play well with the new feature. Notably, when you [defined a variable](https://github.com/xonixx/fhtagn/blob/f36d84f9593ed93b7f3b4704dbcd1daaa4c81992/Makesurefile#L5) there was [no way to reference it in a parameterized goal argument](https://github.com/xonixx/fhtagn/blob/f36d84f9593ed93b7f3b4704dbcd1daaa4c81992/Makesurefile#L70), so you needed copy-paste.    

https://github.com/xonixx/makesure/issues/139

Considerations: https://github.com/xonixx/makesure/blob/main/docs/revamp_define.md

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



