---
layout: post
title: 'TODO'
description: 'TODO'
image: TODO
---

# On one approach to implementing self-update

_September 2025_

[Makesure](https://makesure.dev) is a task/command runner that I am developing. It is somewhat similar to the well-known `make` tool, but [without most of its idiosyncrasies](makesure-vs-make.md) (and with a couple of unique features!).

Being [zero-install](https://makesure.dev/Installation.html) it needs a way to self-update.

This is implemented by option `-U`/`--selfupdate`:

```sh
./makesure -U
```

Under the hood it is implemented by downloading the latest version of the utility executable and replacing the current one.
                                                                                            
The most important thing here is how to determine the latest version.

For a long time it was implemented by simply checking the version in the most recent utility source file stored in the GitHub repo:
`https://raw.githubusercontent.com/xonixx/makesure/main/makesure?token=$RANDOM`. 

The trick with `?token=$RANDOM` [was needed](https://stackoverflow.com/a/79080107/104522) to overcome caching. By default, GitHub caches raw links [for an unpredictable amount of time](https://news.ycombinator.com/item?id=34761284) (from minutes to, sometimes, days).

This trick was "patched" by GitHub, effectively breaking it. Now adding the parameter results in a 404 error.

Now, what options do we have?

Probably, the most correct one is to maintain a separate file (like a text file or JSON) on our own server with a list of all releases and their versions.
                                             
I didn't want to go this route right now because the maintenance complexity of this solution would be much higher than the current scale of the project.

Another option would be to use the GitHub API to get the latest release version.

I did try this approach, but the main obstacle here appeared to be the aggressive [rate limiting applied by GitHub](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api?apiVersion=2022-11-28).

Let me demonstrate. 

At first, [I tried](https://github.com/xonixx/makesure/commit/8c645e3a67f76e369117702211fee607f95be327) to get the latest commit hash and use it to reliably fetch the most recent (not stale) version of the file.

Quickly I realized my [self-update integration test](https://github.com/xonixx/makesure/blob/main/tests/200_update.tush) breaks in GitHub Actions (unfortunately, logs are expired, so cannot show). In my pipeline I run the test suit over multiple OSes in parallel.

It's important to note that I could do a compromise and exclude the test from the CI pipeline. It's unlikely that rate limiting will be triggered for final users. Unlikely, but not impossible. What if users sit inside a corporate network (i.e. behind a single IP) and decide to update the utility simultaneously?  

My [next attempt](https://github.com/xonixx/makesure/commit/ab176c696b5177f1912095e75d025c057ded3f89) to outsmart GitHub (haha, how naive I was) was to download and parse the HTML page instead of the API/JSON one.

Apparently, this triggered yet another level of rate limiting which covers the GitHub UI part.

For some reason I kept persisting. I [attempted](https://github.com/xonixx/makesure/commit/54b167b48f46eb335fc9b8586a1b2e0a61b2f41b) yet another page with the predictably same result.

All in all, it appeared that GitHub represented an inscrutable wall here. 

Basically, if you want to implement the mechanism staying solely in the realm of GitHub, you have to choose between:

1. Aggressive caching of raw links (`raw.githubusercontent.com`) (but no rate limiting!)
2. Aggressive rate limiting of the GitHub API (`api.github.com`) and GitHub UI (`github.com`) (but no caching!)

And if you think about it, these constraints make a lot of sense for the resilience of such a big service as GitHub.

---
 
Is there a way out? I found one, I called it "incremental strategy".

The idea is simple. Can we predict the next release version? Well, if the current version of the utility is [0.9.24](https://github.com/xonixx/makesure/releases/tag/v0.9.24) it seems reasonable to expect the next one to be [0.9.25](https://github.com/xonixx/makesure/releases/tag/v0.9.25).

If we know the next version beforehand, we can download the file from a (now known) raw link (in this case `https://raw.githubusercontent.com/xonixx/makesure/v0.9.25/makesure`), and there won't be any caching-related problem!

How cool is that?

And that's exactly [what I've implemented](https://github.com/xonixx/makesure/compare/9e879557d95c501584f783bbb05db3f43e79920d...d3d1c8d1e5631be066a8925b9742b4278cef492e).

---

Does this solution have drawbacks? Lots of!

- No easy way to implement a major version update (e.g. from 0.9.24 to 1.0.0) or any other versioning scheme change.
- No easy way to retract a broken/vulnerable release.
- Complexity in handling the update over multiple versions. From 0.9.24 we need to attempt 0.9.25, 0.9.26, 0.9.27, etc., till we find there is no more.
- Relying on a third-party service and its mechanisms always brings additional stability risks.
- I'm sure there are more.

The implemented approach is not ideal for sure. For a more robust self-update implementation, it needs to support our own server with a release versions file.

Even better - distribute the utility via the default package managers on every OS, but the implementation efforts are monumental 🤯.

I decided not to do any of this to keep it manageable for me.






