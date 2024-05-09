#!/bin/bash
cd `dirname $0`
if [[ $# -ne 1 ]];then
    echo "Input slug" >&2
    exit 1
fi
dir_name=books
slug_prefix=book
slug_name=$1
echo -en "$slug_name" | grep -E "[a-z0-9]+([_-][a-z0-9])+" > /dev/null
if [[ $? -ne 0 ]];then
    echo "Invalid Slug, must contain -_" >&2
    exit 1
fi
WC=`echo -en "$slug_name" | wc -m`
if [[ $WC -lt 12 || $WC -gt 40 ]];then
    echo "Invalid Slug, must 12-40" >&2
    exit 1
fi

ls -1 ./${dir_name}/ | grep $slug_name
if [[ $? -eq 0 ]];then
    echo "Already exist slug: "${slug_name} >&2
    exit 1
fi
echo "slug_name: $slug_name"

git checkout -b "${slug_prefix}/${slug_name}" && \
npx zenn new:book --published true --slug $slug_name

mkdir -v ./images/${dir_name}/${slug_name} && touch ./images/${dir_name}/${slug_name}/.gitkeep