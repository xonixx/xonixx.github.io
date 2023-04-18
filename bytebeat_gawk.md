---
layout: post
title: 'Bytebeat with Gawk'
description: "TODO"
image: https://img.youtube.com/vi/qOenoyBO7XY/0.jpg
---

# Bytebeat with Gawk

_April 2023_

Not long ago I came across this link http://kmkeen.com/awk-music/. The blog post describes a simple awk script that is able to generate harmonious audio sounds. 

I immediately recalled the [bytebeat](http://countercomplex.blogspot.com/2011/10/algorithmic-symphonies-from-one-line-of.html) - a technique of generating interesting sound effects and even the whole melodies in couple lines of C code.

I thought -- would it be possible (just for fun, of course) to convert some of bytebeats from C to GAWK? Why AWK? Because [I'm fan of it](awk.md). Why particularly GNU AWK? Because only GNU AWK variant has built-in [bitwise functions](https://www.gnu.org/software/gawk/manual/html_node/Bitwise-Functions.html).    

[![Bytebeat with Gawk](https://img.youtube.com/vi/qOenoyBO7XY/0.jpg)](https://www.youtube.com/watch?v=qOenoyBO7XY)

- TODO learnings:
- TODO playback on linux
- TODO output binary from awk/gawk
- TODO gawk bitwise functions + the problem with them
- TODO https://lists.gnu.org/archive/html/bug-gawk/2023-03/msg00005.html
- TODO bitwise handling in other languages
- TODO technique to debug the generated binary output
- TODO c operators priorities
- TODO https://en.wikipedia.org/wiki/Two%27s_complement
- TODO measure generation speed
- TODO conclusion : try converting bytebeat to your favorite language 