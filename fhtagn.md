---
layout: post
title: 'TODO'
description: 'Literate testing for command-line programs with fhtagn'
image: TODO
---

# fhtagn - tiny CLI programs tester written in AWK

_June 2023_

## What is it?

`fhtagn.awk` is a [tiny](https://github.com/xonixx/fhtagn/blob/0e70ab0329858ebbfd22b74bbf6fb51cb3e6d359/fhtagn.awk) CLI tool for literate testing for command-line programs.

What does it mean literate testing?
                 
Let's say you created some program `command`. You want to create a set of end-to-end tests for it. 

With fhtagn it's as simple as creating a file `tests.tush` with the following content:

```
$ command --that --should --execute correctly
| expected stdout output

$ command --that --will --cause error
@ expected stderr output
? expected-exit-code
```

And running it:
   
```shell
./fhtagn.awk tests.tush
```
    
In case of success ...

## Why rewrite?

### Results

