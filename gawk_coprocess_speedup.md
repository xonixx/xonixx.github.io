---
layout: post
title: 'Using GAWK coprocess to speed up the script 50x'
description: 'I describe a small but efficient optimization in my script'
---

# Using GAWK coprocess to speed up the script 50x

_February 2023_

In a need to parse some logs, extract values from it, and convert a value from hex to decimal, I came up with this GAWK script:

```awk
match($0, /larger than 15 chars: (.+) actual size is: 19 .+ GUID: (.+),/, arr) {
  print arr[1],arr[2],hex2dec(arr[2])
}

function hex2dec(h,   s,res) {
  s = "echo \"obase=10; ibase=16; " h "\" | bc"
  s | getline res
  close(s)
  return res
}
```

Note, the conversion hex → dec is done via [bc](https://www.gnu.org/software/bc/manual/html_mono/bc.html). 

Why is that? Well, it appears, that if you do it in native GAWK, you'll get the incorrect result due to the precision loss:

```shell
# correct
$ echo "obase=10; ibase=16; 11000187D6CAA7BD" | bc
1224980781580593085

# incorrect
$ gawk 'BEGIN { print strtonum("0x11000187D6CAA7BD") }'
1224980781580593152
```

But this appears to be rather slow, because we start a new `bc` subprocess for each log line.
   
## Fix

[Coprocess](https://www.gnu.org/software/gawk/manual/html_node/Getline_002fCoprocess.html) to the resque!

```awk
match($0, /larger than 15 chars: (.+) actual size is: 19 .+ GUID: (.+),/, arr) {
  print arr[1],arr[2],hex2dec(arr[2])
}

BEGIN {
  print "obase=10; ibase=16;" |& "bc"
}

function hex2dec(h,   res) {
  print h |& "bc"
  "bc" |& getline res
  return res
}
```

Now we start only one `bc` subprocess--which runs in parallel with our code--and interactively write hexes to it and read decimals back. 

## Result

| Before   | After   |
|----------|---------|
| 34.260 s | 0.608 s |

This is **50x +** speedup! 🥳


