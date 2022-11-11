#!/bin/sh

build_version=$(git describe --always --tags --long --dirty=-dev)
build_verbose=$(git log --pretty=format:"%H | %s | %ad" --date=iso8601-strict -n 1)
build_branch=$(git symbolic-ref --short HEAD 2> /dev/null)
build_date=$(date -Iseconds)
# if [ "master" = ${build_branch}]
# then
#     build_branch=""
# else
#     build_branch="-dev"
# fi

echo "Build Version: ${build_version}"
echo "Build Branch: ${build_branch}"
echo "Build Date: ${build_date}"
echo "Build Verbose: ${build_verbose}"
sed -e "s#@VERSION@#${build_version}#" -e "s#@BRANCH@#${build_branch}#" -e "s#@DATE@#${build_date}#"  -e "s#@VERBOSE@#${build_verbose}#" "$1" > "$2"
