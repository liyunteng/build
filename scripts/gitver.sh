#!/bin/sh

tags=$(git describe --always --tags)
verbose=$(git log --pretty=format:"%H | %s | %ad" --date=iso8601-strict -n 1)
branch=$(git symbolic-ref HEAD 2> /dev/null | cut -b 12-)
date=$(date -Iseconds)
# if [ "master" = $branch ]
# then
#     branch=""
# else
#     branch="-dev"
# fi

echo "Version:" "$tags"
echo "Branch:" "$branch"
echo "Verbose:" "$verbose"
echo "Date:" "$date"
sed -e "s/@VERSION@/$tags/" -e "s/@BRANCH@@/$branch/" -e "s/@VERBOSE@/$verbose/" -e "s/@DATE@/$date/" "$1" > "$2"
