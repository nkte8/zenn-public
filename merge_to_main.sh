#!/bin/bash
cd `dirname $0`
current_branch=$(git branch --contains | awk '{ print $2 }')

set -x
git checkout main
GIT_MERGE_AUTOEDIT=no git merge --no-ff ${current_branch}

git push
git checkout ${current_branch}
