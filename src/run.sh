#!/bin/sh

set -e

ipsum
./update_index_tags.py
./prune_rss.py
