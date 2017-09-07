#!/usr/bin/env bash

set -e # halt script on error

bundle exec jekyll build
mv _site site # looks like deploy phase doesn't like underscores
echo www.cmlteam.com > site/CNAME # custom domain