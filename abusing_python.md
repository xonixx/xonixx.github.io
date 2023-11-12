---
layout: post
title: "Abusing Python's list comprehensions"
description: 'My ancient article revived from Blogspot'
image: python.png
---

# Abusing Python's list comprehensions

_December 2008_

<sup>(This is an ancient article revived from my Blogspot)</sup>

It appears, it's enough only list comprehensions to program in Python:

```python
[ [[[[[
  (
    (
      p('Multiplications:'),
      doMult(4, 10),
      l()
    ),
    (
      p(),
      p('Fib:'),
      [
        (
          p('%d->%d' % (i, fib(i)))
        )
        for i in range(1, 10)
      ]
    ),
    (
      p(),
      p('Qsort:'),
      p(qsort([2,1,4,-11,9]))
    )
  )
  
  for doMult in [lambda I, J:
    [
      (
        l() if j==1 else [],
        p('%sx%s=%s' % (i, j, i * j))
      )
      for i in range(1, I)
      for j in range(1, J)]
  ]]  
  
  for qsort in [lambda L:
      [] if L==[]
        else [
          qsort([e for e in T if e<=H]) + [H] + qsort([e for e in T if e>H])
            for H in [L[0]]
            for T in [L[1:]]
          ][-1]
  ]]
  
  for fib in [lambda n:
    n if n<2 else fib(n-1) + fib(n-2)
  ]]
  
  for l in [lambda:
    p('-' * 10)    
  ]]  
  
  for p in [lambda s='':
    w(str(s)+'\n')
  ]]
  
  for w in [
    __import__('sys').stdout.write
  ]
]
```
 
Output:

```
Multiplications:
----------
1x1=1
1x2=2
1x3=3
1x4=4
1x5=5
1x6=6
1x7=7
1x8=8
1x9=9
----------
2x1=2
2x2=4
2x3=6
2x4=8
2x5=10
2x6=12
2x7=14
2x8=16
2x9=18
----------
3x1=3
3x2=6
3x3=9
3x4=12
3x5=15
3x6=18
3x7=21
3x8=24
3x9=27
----------

Fib:
1->1
2->1
3->2
4->3
5->5
6->8
7->13
8->21
9->34

Qsort:
[-11, 1, 2, 4, 9]
```

`¯\_(ツ)_/¯`
