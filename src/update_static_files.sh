#!/bin/sh

# Check that we are runnign at the correct directory level.
if [ ! -d manual ]
then
	echo "Huh, no manual directory found?"
    exit 1
fi

git add .. && git commit -av -m "Updates static files." &&
	git show --stat
