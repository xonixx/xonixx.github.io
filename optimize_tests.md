---
layout: post
title: 'TODO'
description: "The re-write of Spring Boot integration tests resulted in 10x execution speedup"
image: TODO
---

# TODO

_March 2023_

## Problem description

In [CML Team](https://www.cmlteam.com) we are building our (yet internal) CRM system.
It's a traditional web application with Java + Spring Boot + MySQL on the backend and React + Next.js on the frontend.

We have pretty good code coverage for the backend (reaching 80%) with tests, but the integration tests are (as expected) rather slow. It takes 20+ minutes to run on CI server. It's even slower running locally.

Needless to say, this slowness renders tests much less useful and helpful for the developers, since they practically can't run the tests locally often enough.

## Source of slowness

We at CML Team value integration/functional tests (over unit-tests). So we tend to write tests with less mocks, tests that spans all layers of the (Java) application (controllers, services, repositories) -- down to (and including) the DB. The tests run on the real database (MySQL), not often recommended H2. 

Overall, the idea is, the closer your tests follow _real_ (human) use-cases and real application setup, the higher chances to catch _real_ bugs.


## The rewrite approach

## Why the new approach is better?

## Results