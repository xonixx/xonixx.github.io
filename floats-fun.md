---
layout: post
title: 'Fun with floats'
description: 'I experiment with IEEE 754 positive and negative zeros, infinities, and NaNs'
image: floats-fun2.png
---

# Fun with floats

_July 2026_ <span class="no-llm">No LLM was used to write this article</span>

Did you know that floating-point numbers ([IEEE 754](https://en.wikipedia.org/wiki/IEEE_754)) have `0` and `-0`?

![](floats-fun1.png)

Looks like nothing spacial. They are just equal. 
                        
But there is a nuance.

![](floats-fun2.png)

Further more.

![](floats-fun3.png)

Not a number!

Let's try to add infinities

![](floats-fun4.png)

Infinities are infinities, no matter how many you add them up.

Let's try to subtract.

![](floats-fun5.png)

Well, this is very logical, isn't it?

In this regard it is not so logical that infinities are considered to be equal.

![](floats-fun6.png)

It's worth mentioning that `NaN` is the only float that doesn't equal to itself.

![](floats-fun7.png)

Let's continue. Let's consider arithmetics of zeros.

![](floats-fun8.png)

Conclusion: positive zero beats negative.

But not always

![](floats-fun9.png)

