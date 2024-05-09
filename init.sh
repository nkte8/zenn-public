#!/bin/bash
cd `dirname $0`
current_branch=$(git branch --contains | awk '{ print $2 }')

git checkout dev_container

echo "update zenn-cli..."
# docker run --rm -v $PWD:/src -w /src -it node:lts npm install zenn-cli@latest
npm install
git add package*.json

git status | grep modified > /dev/null
[[ $? -eq 0 ]] && git commit -m "[init] node-js package renew"

git push

git checkout $current_branch
GIT_MERGE_AUTOEDIT=no git merge dev_container --no-ff
