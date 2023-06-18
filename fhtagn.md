---
layout: post
title: 'fhtagn -- a tiny CLI programs tester written in AWK'
description: 'Literate testing for command-line programs with fhtagn'
image: fhtagn.png
---

# fhtagn -- a tiny CLI programs tester written in AWK

_June 2023_

[fhtagn](https://github.com/xonixx/fhtagn) is a [tiny](https://github.com/xonixx/fhtagn/blob/764f6ecf600944ef043de3774a67478350740049/fhtagn.awk) CLI tool for literate testing for command-line programs.

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

In case if the actual output of a command line doesn't match the expected output or exit code - the tool will show a `diff` of the expected and the actual results.

- Each test file can have multiple such tests (like the example above have two, as you can see).
- fhtagn will only process lines starting `$`, `|`, `@` and `?`. So you can have any other content there, that doesn't start these symbols, for example description for each test. Alternatively, you can even make test files a markdown and place the tests into code blocks for readability.
- Command lines can be [multiline](https://github.com/xonixx/fhtagn/blob/764f6ecf600944ef043de3774a67478350740049/tests/4-multiline.tush).

I use fhtagn as a testing tool for my projects:
- [makesure](https://github.com/xonixx/makesure)
- [gron.awk](https://github.com/xonixx/gron.awk)
- [awk_lab](https://github.com/xonixx/awk_lab)
- [fhtagn](https://github.com/xonixx/fhtagn) (yes!)

I wrote this tool in AWK. Surprised? Check my article [Fascination with AWK](awk.md).

## tush rewrite

In fact this project is my re-implementation of [darius/tush](https://github.com/darius/tush), so all credit for the idea goes to the original author [Darius Bacon](https://github.com/darius).

But my rewrite is simpler (single tiny AWK script) and faster, because:

- it uses `/dev/shm` where available instead of `/tmp`
- it compares the expected result with the actual in the code and only calls `diff` to show the difference if they don't match
- it doesn't create a sandbox folder for each test
- it doesn't use `mktemp` but rather generates random name in the code

## Design principles

Below I want to elaborate a bit on design principles I've used to achieve the best speed. Basically there are two of them:
- minimize running external processes
- minimize I/O operations

Let's show on examples.

### AWK script, not shell

By using `/usr/bin/awk` shebang instead of `/bin/sh` with subsequent awk invocation we make it one shell process call less. 

### Do more in one shell invocation

[Here](https://github.com/xonixx/fhtagn/blob/764f6ecf600944ef043de3774a67478350740049/fhtagn.awk#L13-L15) we do a single shell invocation and get two values from it. It's faster than doing two separate shell invocations.

### Creating one less file by using stdin

[Here](https://github.com/xonixx/fhtagn/blob/764f6ecf600944ef043de3774a67478350740049/fhtagn.awk#L65) we do 

```shell
echo actual_data | diff expected_file -
```

instead of 
```shell
diff expected_file actual_file
```

Because this allows to skip creating the `actual_file`.

Also note how we combine there the deletion (`rm`) of a temp file in the same call.
           
### Batching cleanup in a single call

[This change](https://github.com/xonixx/fhtagn/pull/17/files) optimizes the temporary files removal. Instead of calling `rm` for each test we collect all temp files into `ToDel` variable and do the actual removal inside the `END` block.

By the way, this issue was identified by [generating](https://github.com/xonixx/fhtagn/blob/764f6ecf600944ef043de3774a67478350740049/gen_speed_test.awk) an arbitrary large synthetic test file and was fixed [in this issue](https://github.com/xonixx/fhtagn/issues/14).

### Results
    
On [makesure](https://github.com/xonixx/makesure) project running the test suite (excluding the tests in `200_update.tush` that does network calls) `./makesure tested_awks`: 
              
| Before (tush*) | After (fhtagn) |
|----------------|----------------|
| 36.1 sec       | 24.2 sec       |

The speedup is **33%**! 

*) For tush I was using the [adolfopa/tush](https://github.com/adolfopa/tush) fork.

## Tricky issue trying to test fhtagn with fhtagn

We test fhtagn with fhtagn! Yes, [we eat our own dog food](https://en.wikipedia.org/wiki/Eating_your_own_dog_food).

In fact, since fhtagn is syntactically fully compatible with tush, for the reference we firstly run the [test suite](https://github.com/xonixx/fhtagn/blob/18f7865f8d58a30a263f45d0378c1e6f0b4c38b5/tests/fhtagn.tush) with tush, and then, as an additional check, we run it [with fhtagn](https://github.com/xonixx/fhtagn/blob/18f7865f8d58a30a263f45d0378c1e6f0b4c38b5/Makesurefile#L60-L61).

Testing fhtag with fhtagn revealed very interesting bug. The test constantly stopped with an error

```
Testing with fhtagn (./fhtagn.awk)...
error reading file: /dev/shm/fhtagn.893568705.out
```

The `.err` and `.out` files [are created](https://github.com/xonixx/fhtagn/blob/18f7865f8d58a30a263f45d0378c1e6f0b4c38b5/fhtagn.awk#L78) for each `$` line to capture stdout and stderr outputs of the executed command line. For some reason, the files were missing! 

Initially I thought that for some mysterious reason, when running fhtagn tests with fhtagn the mentioned files were not created. I spent tons of time debugging this hypothesis. It appears, this was not the case.

Long story short, the files were created, but were then deleted. Let me explain.

When running fhtagn tests with fhtagh what happens is

`fhtagn.awk` (runner) starts `fhtagn.awk` (program under test).

Now, both fhtagn processes generate temporary `.err` and `.out` files with random names. 

I used `rand()` and `srand()` AWK functions to generate a random name for a file. 

It appears, that AWK's

1. [`rand()`](https://www.gnu.org/software/gawk/manual/html_node/Numeric-Functions.html#index-rand_0028_0029-function) always generates the same random sequence unless you set a seed with `srand()`
2. [`srand()`](https://www.gnu.org/software/gawk/manual/html_node/Numeric-Functions.html#index-srand_0028_0029-function) by default sets the seed number that equals to the current timestamp (with 1 sec precision).

At this point you may have already guessed the culprit.

Since the "runner" fhtagn starts the "program under test" fhtagn in under some milliseconds after own start, the seed appears to be equal for both fhtagn processes, so they generate equal "random" file names!

I solved this problem by introducing the [additional source of randomness](https://github.com/xonixx/fhtagn/blob/18f7865f8d58a30a263f45d0378c1e6f0b4c38b5/fhtagn.awk#L15) in the form of the PID of a shell process (`$$`).

The problem was solved.

Overall the dogfooding practice proved to be really useful to stress-test the application.

