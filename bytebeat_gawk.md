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

***

Let's take a look at a simple bytebeat:

```c
// file: a1.c
main(t) {
for(t=0;;t++)putchar(
    t*((t>>12|t>>8)&63&t>>4) // <-- formula that defines the melody
);}
```

Now, to make it play you need:
```
$ cc -w a1.c -o a1
$ ./a1 | aplay -f u8
Playing raw data 'stdin' : Unsigned 8 bit, Rate 8000 Hz, Mono
```

The conversion to GAWK is pretty straightforward:
```awk
# file: a1.awk
BEGIN { for(;;t++)
  printf"%c",t*and(or(rshift(t,12),rshift(t,8)),63,rshift(t,4))
}
```

However, running it, you can immediately notice, that the sound it produces is not the same as of the C source:
```
$ gawk -f a1.awk | aplay -f u8
Playing raw data 'stdin' : Unsigned 8 bit, Rate 8000 Hz, Mono
```

What's the problem?
                        
Obviously, the GAWK variant was generating different stream of bytes, then the C.

Not understanding what's going on, I decided to start from the simplest formula possible: `t`. I also decided to generate a fixed number of bytes (`10000`) by both programs and try to compare the outputs.

```c
// file tmp.c
main(t) {
for(t=0;t<10000;t++)putchar(
    t
);}
```
```awk
# file: tmp.awk
BEGIN { for(;t<10000;t++)
  printf"%c",t
}
```
 
Generating outputs:
```
$ cc -w tmp.c -o tmp
$ ./tmp > tmp.c.out
$ gawk -f tmp.awk > tmp.awk.out
```

The first obvious thing - let's check the length of both files:
```
$ ls -l tmp.*.out
-rw-rw-r-- 1 xonix xonix 27824 Apr 18 20:07 tmp.awk.out
-rw-rw-r-- 1 xonix xonix 10000 Apr 18 20:07 tmp.c.out
```

Here is it! The C output is 10000 bytes long as expected, but GAWK generates a longer file. 

Long story short, it appears that GAWK by default operates on unicode characters, not bytes. But it has [`-b` option](https://www.gnu.org/software/gawk/manual/html_node/Options.html#index-_002db-option) that allows to work with strings as with single-byte characters.

```
$ gawk -b -f tmp.awk > tmp.awk.out
$ ls -l tmp.*.out
-rw-rw-r-- 1 xonix xonix 10000 Apr 18 21:33 tmp.awk.out
-rw-rw-r-- 1 xonix xonix 10000 Apr 18 20:07 tmp.c.out
```

Excellent! Now the sound plays as intended:

```
$ gawk -b -f a1.awk | aplay -f u8
Playing raw data 'stdin' : Unsigned 8 bit, Rate 8000 Hz, Mono
```

- TODO gawk bitwise functions + the problem with them
  - https://lists.gnu.org/archive/html/bug-gawk/2023-03/msg00005.html
  - TODO bitwise handling in other languages
- TODO technique to debug the generated binary output
  - hexdump
  - endiannes
  - tcc
- TODO c operators priorities
- TODO https://en.wikipedia.org/wiki/Two%27s_complement
- TODO measure generation speed
- TODO conclusion : try converting bytebeat to your favorite language 