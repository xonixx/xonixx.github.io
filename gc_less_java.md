---
layout: post
title: 'TODO'
description: 'I describe my experiments with programming Java sans GC'
image: TODO
---

# GC-less (heap-less) Java

_TODO 2024_

## What

https://github.com/xonixx/gc_less - Experiments TODO

## Why

For fun and curiosity. 

Basically I wanted to check if the famous `sun.misc.Unsafe` approach is still viable with latest Java. 

Also, I wanted to try to program in Java like if I program in C and see how it goes.

## How
    
### `sun.misc.Unsafe`

### Epsilon GC

### Generating code by template

### Data structures implementation

### Allocator + try-with-resources

### Ref

### Memory leaks detection

I had an idea to implement memory leaks detection. This appeared [relatively easy to achieve](https://github.com/xonixx/gc_less/blob/3615ee7a490cc353ff7eb7c5a12221a94ed49ebb/src/main/java/gc_less/Unsafer.java#L30). The idea: on each memory allocation we remember the place (we instantiate `new Exception()` to capture a stack trace). On each corresponding memory `free()` we discard it.
Thus, at the end we check what's left.

I implemented a [base test class](https://github.com/xonixx/gc_less/blob/3615ee7a490cc353ff7eb7c5a12221a94ed49ebb/src/test/java/gc_less/MemoryTrackingBase.java) such that test that extend it can automatically ensure the absence of memory leaks.
       
### Using `java.lang.foreign.MemorySegment` 

https://openjdk.org/jeps/8323072

https://openjdk.org/jeps/454#Linking-Java-code-to-foreign-functions

### Python-like hashtable implementation

https://www.fluentpython.com/extra/internals-of-sets-and-dicts/

### Benchmark


