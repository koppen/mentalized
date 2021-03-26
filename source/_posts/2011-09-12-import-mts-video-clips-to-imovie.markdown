---
title: Import MTS video clips to iMovie
date: '2011-09-12 09:43:45 +0200'
mt_id: 2124
categories:
- technology
- software
- movies
- life
description: "I figured out how to convert MTS video files into something iMovie would import without paying for a commercial tool. Here's how to do it."
---
My parents have a digital camcorder. A week long vacation with said camcorder, my parents, and their only grandchild produces a fair amount of raw footage. Before we headed back home after the vacation I wisely snapped up all the footage from their camera hoping to eventually run it through iMovie.

Turns out their camcorder stores its clips in MTS/[AVCHD](http://en.wikipedia.org/wiki/AVCHD) format, and I didn't grab all the fluff^Wnecessary files. As a result iMovie '11 cannot import the MTS video clips.


<!--more-->

I spent the better part of last night trying to figure out how to convert the MTS into something iMovie would import. While there are commercial tools that appear to do what I needed, I was sure I could get the same result using freely available tools. And sure enough [ffmpeg](http://ffmpeg.org) - the swiss army knife of open source video handling - gets the job done.

After reading a bunch of threads and forum posts I finally found these settings to convert from MTS to MOV files that I could import into iMovie '11 without significant loss of quality:

    ffmpeg -i input.mts -b 185M output.mov

That -b flag took me forever to find and I finally spotted it in [this thread](http://vimeo.com/groups/cinelerra/forumthread:3721).

I am not a video buff, so I am sure the above can be optimized, but it worked, and I am posting it here primarily so I know I can find it again.

## Updated december 5, 2012:

So I recently retried what I wrote above. Turns out the version of ffmpeg that I currently have on my machine (<code>ffmpeg version 1.0</code>) needs some slightly different hand waving on the command line:

    ffmpeg -i input.mts -strict -2 output.mov

* <code>-strict -2</code> because some "codec is experimental but experimental codecs are not enabled" and that toggle enables experimental codecs. This appears to be because the input movie was encoded with h264, so your mileage may vary.
