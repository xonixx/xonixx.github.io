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
    
In case of success the tool will output nothing (in Unix tradition of being silent when all is OK).

In case if the expected output of a command line doesn't match the expected output or exit code - the tool will show a `diff` of the expected and the actual results.

- Each test file can have multiple such tests (like the file above have two)
- fhtagn will only process lines starting `$`, `|`, `@` and `?`. So you can have any other content there, that doesn't start these symbols, for example description for each test. Alternatively, you can even make test files a markdown and place the tests into code blocks for readability.   

## Why rewrite?

### Results

