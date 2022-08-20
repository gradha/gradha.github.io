#!/usr/bin/env python3

import glob
import os
import os.path

INDEX="../index.html"
TAGS_GLOB="../tags/*.html"
START="start_tags"
END="end_tags"
TMP="/tmp/update_index_tags.tmp"
before = open(INDEX, "rb").read()

prefix = []
body = []
sufix = []

state = 0
for line in open(INDEX, "rt").readlines():
    if 0 == state: prefix.append(line)
    elif 1 == state: body.append(line)
    else: sufix.append(line)

    if line.find(START) > 0: state = 1
    elif line.find(END) > 0:
        state = 2
        # Move last body line to sufix, since it includes the marker.
        sufix.append(body[-1])
        del body[-1]

body = []
for tag_filename in [os.path.basename(x) for x in sorted(glob.glob(TAGS_GLOB))]:
    name = os.path.splitext(tag_filename)[0]
    body.append("<a href='tags/" + tag_filename + "'>" + name + "</a>\n")

open(TMP, "wt").writelines(prefix + body + sufix)
after = open(TMP, "rb").read()

if before != after:
    print("Tags changed")
    open(INDEX, "wb").write(after)
