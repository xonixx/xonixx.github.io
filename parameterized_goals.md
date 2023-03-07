---
title: 'Adding parameterized goals to makesure'
description: 'Parameterized goals are a great way to declaratively reuse code in makesure'
image: parameterized_goals2.png
---

# Adding parameterized goals to makesure

## What is makesure?

[Makesure](https://github.com/xonixx/makesure) is a task/command runner that
I am developing. It is somewhat similar to the well-known `make` tool, but
[without most of its idiosyncrasies](makesure-vs-make.md) (and with a couple of unique features!).

## The need for parameterized goals

When you write large build files, you inevitably start getting some copy-paste in there. Typical use case: you want to test your code against multiple versions of some software / programming language / compiler.

To illustrate the point, let's imagine that you've written a Python script and want to make sure it runs correctly with both Python 2 and Python 3 (this example is a bit artificial, but good for explaining).

```shell
@goal pythons_tested
@depends_on python2_tested python3_tested

@goal python2_installed
@depends_on soft_folder_created
@reached_if [[ -x ./soft/python2 ]]
  wget "https://software-repository/python2.tar.gz"
  tar xzvf python2.tar.gz --directory ./soft
  rm python2.tar.gz 
 
@goal python2_tested 
@depends_on python2_installed
  if ./soft/python2 script.py
  then
    echo "SUCCESS"
  else
    echo "FAIL"
    exit 1
  fi

@goal python3_installed
@depends_on soft_folder_created
@reached_if [[ -x ./soft/python3 ]]
  wget "https://software-repository/python3.tar.gz"
  tar xzvf python3.tar.gz --directory ./soft
  rm python3.tar.gz 
 
@goal python3_tested 
@depends_on python3_installed
  if ./soft/python3 script.py
  then
    echo "SUCCESS"
  else
    echo "FAIL"
    exit 1
  fi
  
@goal soft_folder_created
@reached_if [[ -d soft ]]
  mkdir soft
```

I guess you see the problem. 

Parameterized goals to the rescue!

```shell
@goal pythons_tested
@depends_on python_tested @args '2'
@depends_on python_tested @args '3'

@goal python_installed @params VERSION
@depends_on soft_folder_created
@reached_if [[ -x ./soft/python$VERSION ]]
  local tgz="python$VERSION.tar.gz"
  wget "https://software-repository/$tgz"
  tar xzvf "$tgz" --directory ./soft
  rm "$tgz" 
 
@goal python_tested @params VERSION 
@depends_on python_installed @args VERSION
  if ./soft/python$VERSION script.py
  then
    echo "SUCCESS"
  else
    echo "FAIL"
    exit 1
  fi

@goal soft_folder_created
@reached_if [[ -d soft ]]
  mkdir soft
```

Much better!

***

For a more realistic example let's consider the build file of my project [intellij-awk](https://github.com/xonixx/intellij-awk) - "the missing IntelliJ IDEA language support plugin for AWK". There, [starting line 119](https://github.com/xonixx/intellij-awk/blob/89d7c22572329c9f122550c69b60597bc0f4e9d9/Makesurefile#L119) I had a rather repetitive set of goals. They were responsible for downloading the HTML documentation files from the [GNU Awk online manual](https://www.gnu.org/software/gawk/manual/html_node/String-Functions.html), processing them, and compiling the resulting file [std.awk](https://github.com/xonixx/intellij-awk/blob/main/src/main/resources/std.awk). This file is then used to provide documentation popups inside the IDE:

![documentation popup inside IDE](parameterized_goals1.png)

And [this is what the same goals look like](https://github.com/xonixx/intellij-awk/blob/cd96a7ec1a10239abe1e7425a43fd16059bcec0a/Makesurefile#L126) after refactoring them using goal parameterization. 

Pretty impressive, huh? To make it more prominent just check [the diff of the change](https://github.com/xonixx/intellij-awk/compare/89d7c22572329c9f122550c69b60597bc0f4e9d9...cd96a7ec1a10239abe1e7425a43fd16059bcec0a#diff-9366ca676ebdcbca92d07386a93b23f5f7e4afab8edc2f1233f7f4118edd9312R122).

***

I want to mention another case for parameterized goals. You see, makesure happened to have a very simple yet powerful facility [@reached_if](https://github.com/xonixx/makesure#reached_if). A goal can declare a condition that it has already been reached. In this case, the goal body (the corresponding shell script) will no longer be executed. This simple mechanism makes it very convenient and declarative to express the **idempotent** logic of work. In other words, to speed up the build, since what has already been done will not be repeated. This feature was inspired by the ideas from Ansible.

No wonder people [started using Makesure as a very simple Ansible replacement](https://github.com/xonixx/makesure/issues/112). But at that time it lacked parameterized goals, and so they again suffered from [repetitive code with no easy way to reuse](https://github.com/xonixx/makesure/issues/112#issuecomment-1242065047).

***

Next, I want to talk a bit about how I designed this function and what principles I followed.

## Design principles

I design the tool very minimalistic. In accordance with the principle [worse is better](https://en.wikipedia.org/wiki/Worse_is_better), all else being equal, I prefer not to add a feature to the project than to add it. In other words, the necessity of a feature must be absolutely outstanding to justify its addition.

*In general, when developing a product or library, it is very important to implement the minimum possible functionality, and exactly the one that users need now. Quite often, developers are tempted to add some obvious improvements and features that are not critical and/or are redundant, simply because it seems simple. Moreover, for the same reason, it is often useful to explicitly exclude certain features/use cases. Because you can always add them later if there is an explicit request from users. Removing an unsuccessful feature can be much more problematic.*

So I used to have [this piece](https://github.com/xonixx/makesure/tree/e54733e43553b3eb656a8b5b03bf6a0be208397f#omitted-features) in the documentation:

> **Omitted features**
> - Goals with parameters, like in [just](https://github.com/casey/just#recipe-parameters)
>   - We deliberately don't support this feature. The idea is that the build file should be self-contained, so have all the information to run in it, no external parameters should be required. This should be much easier for the final user to run a build. The other reason is that the idea of goal parameterization doesn't play well with dependencies. The tool however has limited parameterization capabilities via `./makesure -D VAR=value`.

It appears that actually what we didn't want to support was calling goals with arguments from the CLI. So this part has been [slightly reformulated](https://github.com/xonixx/makesure/tree/b549d2ef575d601de05a9630e527f755a4d83252#omitted-features). 

By themselves, parameterized goals turned out to be a really necessary feature, as shown in the examples above.

## Design considerations

I resisted adding this feature for a long time. First, because of the increasing complexity that would not be needed in a majority of typical `makesure` usage scenarios. But mostly because it's tricky to do while preserving the declarative semantics of dependencies. You see, dependency of one goal on another is fundamentally different from a function call.

Why is that? You see, the dependency tree is resolved by `makesure` before running the goals! This is why, for example, it is possible to report a cycle in dependencies as an error, rather than falling into an infinite execution loop. In addition, the run-only-once semantics for reaching the goals: 

```shell
@goal a
@depends_on b c

@goal b
@depends_on c

@goal c
  echo "Reaching c ..." # must be printed only once
```

But it wasn't impossible. For example, [just](https://github.com/casey/just) does have parameterized goals.

I needed some time to think about the problem in depth. Adding the feature needed lots of thorough considerations to:

- Come up with a good syntax: easy to use and easy to parse.
- Accidentally not to introduce alternative ways to do the same thing.
- Avoid significantly complicating the implementation and adding a lot of KB to the code size. You see, `makesure` is a tiny one-file script [designed to be zero-install](https://github.com/xonixx/makesure/tree/e54733e43553b3eb656a8b5b03bf6a0be208397f#installation), it must be extremely lightweight.  
- Understand all the possible implications of a new feature on existing ones, so make sure they play well in all reasonable combinations.

## Implementation process

The idea of parameterized goals lived in my head for quite some time. The first design attempt was [this](https://github.com/xonixx/makesure/issues/96). But in this form, it turned out to be a dead end (simply, I didn't like the result), so it was discarded.

A lot of time has passed. [Russia started an aggressive and genocidal full scale war against my country 🇺🇦Ukraine](https://en.wikipedia.org/wiki/2022_Russian_invasion_of_Ukraine). 

I started the new design by drafting the basic design points in the [document](https://github.com/xonixx/makesure/blob/main/docs/parameterized_goals.md). 

Obviously, I started with designing the syntax and quickly came up with a solution with two complementary keywords `@params` and `@args` (this was inspired by `async` + `await` from JavaScript):

```shell
@goal greet @params H W
  echo "$H $W!"
  
@goal default
@depends_on greet @args 'hello' 'world' 
@depends_on greet @args 'hi' 'there' 
```        

I also considered the syntax: 
```shell
@goal greet(H, W)
  echo "$H $W!"
  
@goal default
@depends_on greet('hello', 'world') 
@depends_on greet('hi', 'there') 
```

Although the latter is more natural for a programmer, I settled on the former for the following reasons:

1. It's much easier to parse. Remember, "worse is better".
2. The `Makesurefile` syntax is specifically designed to be a valid shell syntax (although the semantics may differ). This gives free syntax highlighting in the IDEs and [on GitHub](https://github.com/xonixx/makesure/blob/main/Makesurefile). 

![Makesurefile highlighting in IDE](parameterized_goals2.png)

[Further](https://github.com/xonixx/makesure/blob/main/docs/parameterized_goals.md#q-default-values), in the same design document I analyzed other aspects of the feature in the form of Q and A. Mostly I strove to answer "No." to most of them in order to keep the feature as limited as possible, but at the same time useful for existing use cases. Some or all of them may be added later if necessary. But it's absolutely important to start with [something really simple but practical](https://world.hey.com/dhh/the-simplest-thing-that-could-possibly-work-8f0d8b43).

[Finally](https://github.com/xonixx/makesure/blob/main/docs/parameterized_goals.md#parameterized-goals-vs-existing-features) I thought through the interaction of a new feature with existing ones.

***

Implementation-wise I had an idea how it should be done. It is better to explain with an example. Given this parameterized goal and its usage:
```shell
@goal greet @params WHO
  echo "Hello $WHO!"
  
@goal greet_all
@depends_on greet @args 'world' 
@depends_on greet @args 'Jane' 
@depends_on greet @args 'John' 
```

we will have some pre-processing step before the execution to "materialize" (or in other words, de-parameterize the goals):

```shell
@goal 'greet@world'
  WHO=world
  echo "Hello $WHO!"
@goal 'greet@Jane'
  WHO=Jane
  echo "Hello $WHO!"
@goal 'greet@John'
  WHO=John
  echo "Hello $WHO!"

@goal greet_all
@depends_on 'greet@world' 
@depends_on 'greet@Jane' 
@depends_on 'greet@John'
```

You see, it's the same logic, but no more parameterized goals. Instead, "materialized" goals are generated according to their usages. I believe the more scientific term for this is [monomorphization](https://en.wikipedia.org/wiki/Monomorphization). 

This was a key step because it allowed the reuse of an existing execution model that could already handle the non-parameterized representation.
                        
Since the problem was now very clear and self-contained, it was logical to solve it separately, apart from the main code. I did this in [separate playground repository](https://github.com/xonixx/awk_lab/blob/main/parameterized_goals.awk). Once this part was done and tested, it was [integrated](https://github.com/xonixx/makesure/blob/v0.9.20/makesure.awk#L615) into the core of the tool.

## Result

The parameterized goals feature has been implemented and delivered in the latest release [0.9.20](https://github.com/xonixx/makesure/releases/tag/v0.9.20).

As I mentioned above, the requirement to keep the tool small was very important. Before the addition the tool [weighed around 20 KB](https://github.com/xonixx/makesure/blob/v0.9.19/makesure). I expected this feature to be quite complex to implement, but I felt it should not take more than 5 KB to add it. Surprisingly, it became [only 2 KB bigger](https://github.com/xonixx/makesure/blob/v0.9.20/makesure)! This is due to [some minification tricks](https://github.com/xonixx/makesure/blob/v0.9.20/Makesurefile#L172) I've added in this release.  

In addition to the refactoring opportunities mentioned above this also allowed [to improve a bit](https://github.com/xonixx/makesure/commit/7a15ad9bcd43aefd70f329c35132a83ea9b1117c) the project's own `Makesurefile`! Yes, [we eat our own dog food](https://en.wikipedia.org/wiki/Eating_your_own_dog_food).

It's also interesting to note that the development and debugging of this new feature [revealed a bug](https://lists.gnu.org/archive/html/bug-gawk/2023-01/msg00026.html) in the latest version of GAWK (already fixed, thanks to Arnold Robbins).
           
***

If you found this article interesting and would like to try the tool for your project, please find [the installation instructions](https://github.com/xonixx/makesure#installation).
