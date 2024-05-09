#!/bin/bash
cd `dirname $0`
r_ver=00$(($(find ./articles/ -name $(date +%Y-%m-%d)* | wc -l) + 1))
article_slug=$(date +%Y-%m-%d)-r${r_ver: -2}
echo "article_slug: $article_slug"

git checkout -b ${article_slug} && \
# docker run --rm -v $PWD:/src -w /src -u `id -u`:`id -g` -it node:lts \
#     npx zenn new:article --published true --slug $(git rev-parse --abbrev-ref HEAD) && \
npx zenn new:article --published true --slug $(git rev-parse --abbrev-ref HEAD)
mkdir -v ./images/${article_slug} && touch ./images/${article_slug}/.gitkeep