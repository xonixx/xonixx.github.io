---
layout: post
title: 'mdbooker -- turn your README.md into a documentation site'
description: "mdbooker -- tiny AWK script that can turn your project's README.md into a documentation site"
image: TODO
---

# mdbooker -- turn your README.md into a documentation site

_TODO 2024_

In this article I want to present you the tiny utility [mdbooker](https://github.com/xonixx/mdbooker). 
It lets me convert the [README.md](https://github.com/xonixx/makesure) of my project into the beautiful documentation site [makesure.dev](https://makesure.dev).

This utility works in conjunction with the amazing [mdBook](https://github.com/rust-lang/mdBook) project.

The project is implemented as a single-file [AWK script](https://github.com/xonixx/mdbooker/blob/main/mdbooker.awk).   

## How it works

`mdBook` generates a documentation site (a "book") from a set of markdown files based on a [SUMMARY.md](https://rust-lang.github.io/mdBook/format/summary.html).

Therefore, `mdbooker` splits your README.md into a set of markdown files (based on titles) and generates the SUMMARY.md.


## Usage

### Step 1: run mdbooker

```sh
REPO=username/reponame \
BOOK=path/to/book_folder \
  awk -f mdbooker.awk README.md
```

where

- `username/reponame` - the GitHub repository where README resides. This is needed to correctly rewrite relative links.
- `path/to/book_folder` (optional, default `./book`) - the output folder for generated markdown files.

### Step 2: run mdBook

```sh
mbdook build
```

### Step 3: deploy the website

The deployment of final html/js/css to the public domain is out of scope of this article.

## Technical details

  
## Alternatives

The only alternative I've found is [Docsify](https://colinhacks.com/essays/docs-the-smart-way) -- small JS lib that renders your README.md as a single-page website. I didn't like it, though, because such single-pages usually give poor user experience.