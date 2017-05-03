This is a framework for testing and profiling PICO-8 sorting routines. It contains my heap sort
implementation, based on the version from [The Graphics Codex](htts://graphicscodex.com). It is
up to 1.5x faster than the [previous fastest](http://www.lexaloffle.com/bbs/?tid=2477) PICO-8
sort I'd found, and about 30x faster than a simple insertion sort on arrays of size 64.

The image below shows that each of the sorts is correct (insertion sort is also stable), and
gives profile results for them. Lower is better on timing.

![](results.png)
