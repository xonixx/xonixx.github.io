---
layout: post
title: 'Experimenting with GC-less (heap-less) Java'
description: 'I describe my experiments with programming Java sans GC'
image: TODO
---

# Experimenting with GC-less (heap-less) Java

_TODO 2024_

## What

https://github.com/xonixx/gc_less - in this repository I did a series of experiments in GC-less (heap-less) Java using `sun.misc.Unsafe` and also the newest alternative `java.lang.foreign.MemorySegment`.

GC-less (heap-less) means we allocate data structures in native memory directly (outside JVM heap). Such structures are not visible to GC. But this means that we are responsible for their (explicit) de-allocations (i.e., manual memory management).                       

## Why

For fun and out of curiosity. 

Basically it started when I wanted to check if the famous `sun.misc.Unsafe` approach is still viable with the latest Java. 

Also, I wanted to try to program in Java like if I program in C and see how it goes.

## How
    
### sun.misc.Unsafe
                   
It was a surprise to find that this class is still supported by the latest (at the time of this writing) Java version 23.

`sun.misc.Unsafe` class is unsafe indeed. You can easily crash your JVM with just a couple lines of code:

![JVM crash with sun.misc.Unsafe](gc_less_java2.png)

Yet still it appears to be [pretty widely used](https://github.com/search?q=getDeclaredField%28%22theUnsafe%22%29&type=code). 
 
Anyway, of interest to us is a [family of methods in this class, related to off-heap memory management](https://blog.vanillajava.blog/2014/01/sunmiscunsafe-and-off-heap-memory.html).

### Data structures implementation

So as a practical application of GC-less (heap-less) style of programming I decided to implement some basic [data structures](https://github.com/xonixx/gc_less/tree/b8dfb903c502ff07bb4d953f6d552ffd63fecd35/src/main/java/gc_less):

- array
- array list
- stack
- hash table
       
Not only was I interested in how easy it is or if it's feasible at all. I also wondered how the performance will compare to plain Java's data structures.

### Generating code by template

Instead of writing separate implementations for each Java type (int, long, double, etc.) I decided to generate them by templates.

This way from a single template (for example, [TemplateArrayList.java](https://github.com/xonixx/gc_less/blob/8fa1fa5858b85ad794c85cf284ffbbbfac3af975/src/main/java/gc_less/tpl/TemplateArrayList.java)) the set on specialized implementations are generated:

- [IntArrayList.java](https://github.com/xonixx/gc_less/blob/8fa1fa5858b85ad794c85cf284ffbbbfac3af975/src/main/java/gc_less/IntArrayList.java)
- [LongArrayList.java](https://github.com/xonixx/gc_less/blob/8fa1fa5858b85ad794c85cf284ffbbbfac3af975/src/main/java/gc_less/LongArrayList.java)
- [DoubleArrayList.java](https://github.com/xonixx/gc_less/blob/8fa1fa5858b85ad794c85cf284ffbbbfac3af975/src/main/java/gc_less/DoubleArrayList.java)

Interesting to note is that the template itself is a runnable code. In fact implementation-wise it corresponds to `long`-specialized version.
This is convenient, because we can [test a template](https://github.com/xonixx/gc_less/blob/8fa1fa5858b85ad794c85cf284ffbbbfac3af975/src/test/java/gc_less/tpl/TemplateArrayListTests.java) and this makes sure all the specialized implementations are correct too.

The generation is implemented in form of a script [gen.awk](https://github.com/xonixx/gc_less/blob/8fa1fa5858b85ad794c85cf284ffbbbfac3af975/gen.awk) ([Why AWK?](awk.md)).

We use annotation [@Type](https://github.com/xonixx/gc_less/blob/8fa1fa5858b85ad794c85cf284ffbbbfac3af975/src/main/java/gc_less/tpl/Type.java) and class [Tpl](https://github.com/xonixx/gc_less/blob/8fa1fa5858b85ad794c85cf284ffbbbfac3af975/src/main/java/gc_less/tpl/Tpl.java) to denote patterns to be replaced by a generator:

![](gc_less_java1.png)

### Epsilon GC

To make sure that we indeed do not (accidentally) consume heap I enabled [the Epsilon GC setting](https://github.com/xonixx/gc_less/blob/7c6730eff1ec22c91f66826114de7943416771ad/Makesurefile#L34).

[Epsilon GC](https://openjdk.org/jeps/318) is "a GC that handles memory allocation but does not implement any actual memory reclamation mechanism. Once the available Java heap is exhausted, the JVM will shut down."
   
### Some implementation details

I implemented the data structures in a slightly "strange" OOP-resembling way.

So, for example, take a look at [IntArrayList](https://github.com/xonixx/gc_less/blob/main/src/main/java/gc_less/IntArrayList.java). 

All the methods of this class are static, because we don't want to allocate object on heap. 

Also, all the methods (except for `allocate`, which plays a role of the constructor) accept `long address` as first parameter. It plays a role of `this` (in a sense, it is somehow analogous to Python's `self` parameter). 

So the usage looks like:

```java
    long address = IntArray.allocate(cleaner,10);
    IntArray.set(address, 7, 222);
    System.out.println(IntArray.get(address, 7));
```

So this `long address` plays a role of a reference. Obviously, with this you can't have inheritance / overriding, but we don't need it.

#### try-with-resources + `Cleaner` and `Ref` classes

The idea of the [Cleaner](https://github.com/xonixx/gc_less/blob/92b526a2eb4c82a44b32623171c3727b04a03ed9/src/main/java/gc_less/Cleaner.java) class is you pass the instance of it in the allocation procedure of a (GC-less) class, such that the `Cleaner` becomes responsible for free-ing the memory of the allocated instance. This plays best with try-with-resources.

```java
    try (Cleaner cleaner = new Cleaner()) {
      long array = IntArray.allocate(cleaner,10);
      IntArray.set(array,1,1);
      long map = IntHashtable.allocate(cleaner,10,.75f);
      map = IntHashtable.put(map,1,1); 
      /*
        Why do we re-assign the map? 
        It's because when the data structure grows,
        it can eventually overgrow its initially-allocated memory region. 
        The algorithm will re-allocate the bigger internal storage which will cause
        the address change. 
      */
      map = IntHashtable.put(map,2,22);
      System.out.println(IntArray.getLength(array));
      System.out.println(IntHashtable.getSize(map));
    }
    // both array and map above are de-allocated, memory reclaimed
```

[Ref](https://github.com/xonixx/gc_less/blob/92b526a2eb4c82a44b32623171c3727b04a03ed9/src/main/java/gc_less/Ref.java) class is needed when we want to register some object for cleanup. But we can't simply register its address, because the object can be relocated due to memory reallocation due to growing. So it means, the GC-less object registers for cleanup by `Cleaner` [via the `Ref`](https://github.com/xonixx/gc_less/blob/92b526a2eb4c82a44b32623171c3727b04a03ed9/src/main/java/gc_less/IntArrayList.java#L28) and then the `Ref` pointer gets updated [on each object relocation](https://github.com/xonixx/gc_less/blob/92b526a2eb4c82a44b32623171c3727b04a03ed9/src/main/java/gc_less/IntArrayList.java#L72). 

### Memory leaks detection

I had an idea to implement memory leaks detection. This appeared [relatively easy to achieve](https://github.com/xonixx/gc_less/blob/3615ee7a490cc353ff7eb7c5a12221a94ed49ebb/src/main/java/gc_less/Unsafer.java#L30). The idea: on each memory allocation we remember the place (we instantiate `new Exception()` to capture a stack trace). On each corresponding memory `free()` we discard it.
Thus, at the end we check what's left.

![Memory leak detection demo](gc_less_java4.png)

I implemented a [base test class](https://github.com/xonixx/gc_less/blob/3615ee7a490cc353ff7eb7c5a12221a94ed49ebb/src/test/java/gc_less/MemoryTrackingBase.java) such that test that extends it can automatically ensure the absence of memory leaks.
               
### Visual demonstration
               
So we can say that one of the benefits of manual memory management off-heap is _deterministic memory usage_. 

The class [Main4](https://github.com/xonixx/gc_less/blob/85985326c2503126be6b0f1934bfc187713db70b/src/main/java/gc_less/Main4.java) provides a visual demonstration of allocation and de-allocation in a loop as seen via memory graph of Task Manager:

![Visual demonstration](gc_less_java3.png)

### Using `java.lang.foreign.MemorySegment`

It appears, that very recently this JEP emerged: ["Deprecate Memory-Access Methods in sun.misc.Unsafe for Removal"](https://openjdk.org/jeps/8323072).

This means that despite using memory-access methods in `sun.misc.Unsafe` is fun and sometimes useful, we can no longer rely on this functionality. 

The JEP happens to provide the safer alternatives. I decided to take a deeper look at the updated API and understand how it compares to now deprecated `sun.misc.Unsafe`.

As an alternative we now have `java.lang.foreign.MemorySegment` class. It's worth mentioning that this class is a part of a bigger API, dedicated to ["invoking foreign functions (i.e., code outside the JVM)"](https://openjdk.org/jeps/454) that enables "Java programs to call native libraries and process native data without the brittleness and danger of JNI".

Overall I found that the new API provides a "managed" API over the native memory. That is, when previously we accessed memory via `long` that represented the raw memory address, now we have `java.lang.foreign.MemorySegment` object (that represents both a _pointer_ and a _memory region_). 

This is, obviously, good. Using a dedicated get/set methods from that class gives much safer guarantees, like, for example, built-in out-of-bounds access checks, control of accessing properly aligned memory, etc.

It can seem that this API is much heavier. For every off-heap allocation we need to have an on-heap handle in the form of `MemorySegment` instance. So, we can think that this can render the idea of using the algorithms with lots of small allocations non-viable.  
 
Surprisingly, this is not the case!

My `sun.misc.Unsafe`-based [hashtable implementation](https://github.com/xonixx/gc_less/blob/85985326c2503126be6b0f1934bfc187713db70b/src/main/java/gc_less/tpl/TemplateHashtable.java) is an example of an algorithm that uses many allocation. It's a well-known hashtable algorithm (analogous to standard Java's `HashMap`), with an array of buckets filled based on the hash code, and using linked lists of nodes for elements.

For the sake of experiment I [converted it](https://github.com/xonixx/gc_less/blob/85985326c2503126be6b0f1934bfc187713db70b/src/main/java/gc_less/no_unsafe/tpl/TemplateHashtable.java) to `MemorySegment`. I was expecting that, because of many `MemorySegment` objects allocated, its JVM heap consumption will be proportional to the hashtable size.

Instead, experiment shows that the heap memory consumption is rather O(1).

### How is this possible? 

### Python-like hashtable implementation

While doing these experiments I was lucky enough to meet this article: [Internals of sets and dicts](https://www.fluentpython.com/extra/internals-of-sets-and-dicts/). It describes the implementation details of sets and maps in the Python programming language.

It appears, that the `dict` (this is the name for hashtable in Python) algorithm in Python doesn't use many allocations. Instead, it allocates one piece of memory and distributes the key, value, hashes data in it. When collection grows, it re-allocates this continuous piece of memory and re-distributes the data. This is exactly what we need!
             
So I came up with this `MemorySegment`-based, [Python-based off-heap hashtable implementation](https://github.com/xonixx/gc_less/blob/85985326c2503126be6b0f1934bfc187713db70b/src/main/java/gc_less/python_like/IntHashtableOffHeap.java).

Indeed, this appears to be working solution!

### Stress test with limited heap
                        
With Java it's inevitable, that even if you implement an off-heap algorithm, some heap will be used. So we can only consider an off-heap algorithm practical if it consumes small/fixed amount of heap. Otherwise, if its additional consumption of heap is proportional to the problem size, off-heap doesn't make much sense.  

I've created this small [experiment](https://github.com/xonixx/gc_less/blob/77cd4a6845f297ff7a0dce788dea7bbf391e6385/src/main/java/gc_less/MainHashtableComparison.java) - a program that allocates a hashtable and fills it with 50 million of elements for each of 3 implementation:

- `Unsafe`-based hashtable
- Python-based hashtable
- `MemorySegment`-based hashtable

The experiment runs with Epsilon-GC with heap size [fixed at 20 MB](https://github.com/xonixx/gc_less/blob/77cd4a6845f297ff7a0dce788dea7bbf391e6385/Makesurefile#L35).

We can confirm that all three implementation pass the test with this heap limit.

```
[0.002s][info][gc] Using Epsilon
[0.003s][warning][gc,init] Consider enabling -XX:+AlwaysPreTouch to avoid memory commit hiccups
[0.011s][info   ][gc     ] Heap: 20480K reserved, 20480K (100.00%) committed, 1060K (5.18%) used

===== Unsafe-based hashtable =====
Unsafe-based: 0
Unsafe-based: 1000000
Unsafe-based: 2000000
Unsafe-based: 3000000
...
Unsafe-based: 47000000
Unsafe-based: 48000000
Unsafe-based: 49000000
Freeing...
Freeing local addr 140590889037840...
Freeing local ref  140596292148752...
Freeing locals     140596292147328...

===== MemorySegment-based hashtable =====
[16.869s][info   ][gc     ] Heap: 20480K reserved, 20480K (100.00%) committed, 2106K (10.28%) used
[16.941s][info   ][gc     ] Heap: 20480K reserved, 20480K (100.00%) committed, 3159K (15.43%) used
[16.980s][info   ][gc     ] Heap: 20480K reserved, 20480K (100.00%) committed, 4262K (20.82%) used
[17.019s][info   ][gc     ] Heap: 20480K reserved, 20480K (100.00%) committed, 5438K (26.55%) used
MemorySegment-based: 0
[17.084s][info   ][gc     ] Heap: 20480K reserved, 20480K (100.00%) committed, 6665K (32.55%) used
[17.129s][info   ][gc     ] Heap: 20480K reserved, 20480K (100.00%) committed, 7894K (38.55%) used
[17.165s][info   ][gc     ] Heap: 20480K reserved, 20480K (100.00%) committed, 9123K (44.55%) used
[17.186s][info   ][gc     ] Heap: 20480K reserved, 20480K (100.00%) committed, 10352K (50.55%) used
[17.203s][info   ][gc     ] Heap: 20480K reserved, 20480K (100.00%) committed, 11581K (56.55%) used
MemorySegment-based: 1000000
MemorySegment-based: 2000000
MemorySegment-based: 3000000
...
MemorySegment-based: 47000000
MemorySegment-based: 48000000
MemorySegment-based: 49000000

===== Python-based hashtable =====
Python-based: 0
Python-based: 1000000
Python-based: 2000000
Python-based: 3000000
...
Python-based: 47000000
Python-based: 48000000
Python-based: 49000000
[33.169s][info   ][gc     ] Heap: 20480K reserved, 20480K (100.00%) committed, 11993K (58.56%) used
```

### Benchmarks
