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

## The items to take into consideration

## Implementation concerns