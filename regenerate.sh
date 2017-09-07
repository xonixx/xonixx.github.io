#!/usr/bin/env bash

jekyll build
cd _site
rm *.iml *.sh
cp -r * ~/proj/xonixx.github.io/
