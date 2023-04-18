---
layout: post
title: 'Bytebeat with Gawk'
description: "TODO"
image: https://img.youtube.com/vi/qOenoyBO7XY/0.jpg
---

# Bytebeat with Gawk

_April 2023_

Not long ago I came across this link http://kmkeen.com/awk-music/. The blog post describes a simple awk script that is able to generate harmonious audio sounds. 

I immediately recalled the [bytebeat](http://countercomplex.blogspot.com/2011/10/algorithmic-symphonies-from-one-line-of.html) -- a technique of generating interesting sound effects and even the whole melodies in couple lines of C code.

I thought -- would it be possible (just for fun, of course) to convert some of bytebeats from C to GAWK? 

Why AWK? Because [I'm a huge fan of it](awk.md). Why particularly GNU AWK? Because only GNU AWK variant has built-in [bitwise functions](https://www.gnu.org/software/gawk/manual/html_node/Bitwise-Functions.html).

Below I would like to share with you the result of my effort (link to YouTube, please turn down the volume a bit before you click, just in case):

[![Bytebeat with Gawk](https://img.youtube.com/vi/qOenoyBO7XY/0.jpg)](https://www.youtube.com/watch?v=qOenoyBO7XY)

- TODO learnings:
- TODO playback on linux

The idea of bytebeat is pretty simple. It exploits the old Unix principle that [everything is a file](https://en.wikipedia.org/wiki/Everything_is_a_file). So generating music this way is as easy as running:

```
./prog > /dev/dsp
```

Where `./prog` is a (compiled C, for example) program, that outputs stream of bytes, and `/dev/dsp` is a "virtual file" representing the audio input device.

Unfortunately, modern Linuxes don't expose audio devices in form of a file. 

However, nowadays, you have plenty of ways to achieve the similar result. For example, in Linux you have `aplay` command -- "command-line sound player for ALSA soundcard driver". So, the same command looks like

```
./prog | aplay
```

- TODO output binary from awk/gawk
- TODO gawk bitwise functions + the problem with them
- TODO https://lists.gnu.org/archive/html/bug-gawk/2023-03/msg00005.html
- TODO bitwise handling in other languages
- TODO technique to debug the generated binary output
- TODO c operators priorities
- TODO https://en.wikipedia.org/wiki/Two%27s_complement
- TODO measure generation speed
- TODO conclusion : try converting bytebeat to your favorite language 