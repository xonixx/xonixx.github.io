---
title: 'Adding parameterized goals to makesure'
description: 'Parameterized goals - great way to declarative code reuse in makesure'
image: makesure.png
---

# Adding parameterized goals to makesure

## What is makesure?

[Makesure](https://github.com/xonixx/makesure) is a task/command runner that
I’m developing. It’s sort of similar to the well-known `make` tool, but
[without most of its idiosyncrasies](makesure-vs-make.md) (and with a couple of unique features!).

## The need for parameterized goals

When you write big build files, inevitably you start getting some copy-paste in there. Typical use case: you want to test your code against multiple versions of some software / programming language / compiler.

To illustrate the point let's imagine you wrote a python script and want to make sure it runs correctly with both Python 2 and Python 3 (this example is a bit artificial, but good for explanation).

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

I guess you see the issue. 

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

For more realistic example let's consider the build file of my project [intellij-awk](https://github.com/xonixx/intellij-awk) - the missing IntelliJ IDEA language support plugin for AWK. There, [starting line 119](https://github.com/xonixx/intellij-awk/blob/89d7c22572329c9f122550c69b60597bc0f4e9d9/Makesurefile#L119) I had some rather repetitive set of goals. They were responsible for downloading HTML documentation files from [Gawk online manual](https://www.gnu.org/software/gawk/manual/html_node/index.html), processing them and compiling the resulting file [std.awk](https://github.com/xonixx/intellij-awk/blob/main/src/main/resources/std.awk). This file is then used to provide documentation popups inside IDE:

![documentation popup inside IDE](parameterized_goals1.png)

And [this is how the same goals look](https://github.com/xonixx/intellij-awk/blob/cd96a7ec1a10239abe1e7425a43fd16059bcec0a/Makesurefile#L126) after the refactoring them using goal parameterization. 

Pretty impressive, huh? To make it more prominent just check [the diff of the change](https://github.com/xonixx/intellij-awk/compare/89d7c22572329c9f122550c69b60597bc0f4e9d9...cd96a7ec1a10239abe1e7425a43fd16059bcec0a#diff-9366ca676ebdcbca92d07386a93b23f5f7e4afab8edc2f1233f7f4118edd9312R122).

***

I want to mention also the other case for parameterized goals. You see, makesure happened to have very simple yet powerful facility [@reached_if](https://github.com/xonixx/makesure#reached_if). A goal can declare a condition that it has already been reached. In this case, the goal body (the corresponding shell script) will no longer be executed. This simple mechanism makes it very convenient and declarative to express the **idempotent** logic of work. In other words, to speed up the build, since what has already been done will not be repeated. This feature has been inspired by ideas from Ansible.

No wonder people [started using Makesure as very simple Ansible replacement](https://github.com/xonixx/makesure/issues/112). But at that time it lacked the parameterized goals, and so again they suffered from [repetitive code with no easy way to reuse](https://github.com/xonixx/makesure/issues/112#issuecomment-1242065047).

***

Next, I want to talk a bit about how I designed this function and what principles I followed.

## The items to take into consideration

I design the tool very minimalistic. In accordance with the principle [worse is better](https://en.wikipedia.org/wiki/Worse_is_better) all else being equal I prefer not to add a feature to the project than to add it. In other words, the necessity of a feature must be absolutely outstanding to justify its addition.

*And in general, when developing a product or library, it is very important to implement the minimum possible functionality, and exactly the one that users need now. Quite often, developers are tempted to add some obvious improvements and features that are not critical and/or are redundant, simply because it seems simple. Moreover, for the same reason, it is often useful to explicitly exclude certain features/use cases. Because you can always add them later if there is an explicit request from users. Removing some kind of unsuccessful feature can be much more problematic.*

So I used to have [this piece](https://github.com/xonixx/makesure/tree/e54733e43553b3eb656a8b5b03bf6a0be208397f#omitted-features) in documentation.

> **Omitted features**
> - Goals with parameters, like in [just](https://github.com/casey/just#recipe-parameters)
>   - We deliberately don't support this feature. The idea is that the build file should be self-contained, so have all the information to run in it, no external parameters should be required. This should be much easier for the final user to run a build. The other reason is that the idea of goal parameterization doesn't play well with dependencies. The tool however has limited parameterization capabilities via `./makesure -D VAR=value`.

## Implementation concerns