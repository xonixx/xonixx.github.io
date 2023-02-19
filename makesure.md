---
title: 'makesure - make with a human face'
description: 'I describe the ideas behind the makesure tool and the development process for one of its aspects.'
image: makesure.png
---
[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://stand-with-ukraine.pp.ua)

# makesure - make with a human face

_February 2023_

How many of you use all sorts of helper shell scripts in your projects? It can also be Python or Perl scripts. Typically, such scripts are used during the build phase or for other project automation tasks.

Examples of such tasks are:
- helper scripts for Git,
- running tests/linters,
- launching the necessary docker containers,
- running database migrations,
- actually, building the project,
- documentation generation,
- automating the publication of releases,
- deployment, etc.

Often, build tools are used for such purposes.

[Make](https://en.wikipedia.org/wiki/Make_(software)) is perhaps the most famous of them.

Similar functionality is known to nodejs developers and loved by them in the form of scripts in package.json (npm run-scripts). Java veterans will remember Ant.

But nodejs/Ant needs to be installed. `make`, although capable of serving as a *task runner*, is rather inconvenient in this role, being in fact a very old school *build tool* with all the ensuing consequences.

And the shell scripts require some system and inevitable routine in writing (argument handling, help messages, etc.). Although, for example, [Taskfile](https://github.com/adriancooney/Taskfile) is a great template for such scripts.

And so [makesure](https://github.com/xonixx/makesure) was born.

What is it? It's a tool that understands a `Makesurefile` like this:

```shell
@goal downloaded
@doc 'downloads the code archive'
@reached_if [[ -f code.tar.gz ]]
   wget http://domain/code.tar.gz
  
@goal extracted
@doc 'extracts the code'
@depends_on downloaded
   tar xzf code.tar.gz

@goal built
@doc 'builds the project'
@depends_on extracted
   npm install
   npm run build

@goal deployed
@doc 'deploys the built project'
@depends_on built
   scp -C -r build/* user@domain:~/www

@goal default
@depends_on deployed
```

In essence, these are named pieces of the shell (called goals) combined in one file. This makes it easy to list the goals (with explanatory text):
```
$ ./makesure -l
Available goals:
  downloaded : downloads the code archive
  extracted  : extracts the code
  built      : builds the project
  deployed   : deploys the built project
  default
```
and call any of them by name:
```shell
$ ./makesure deployed
$ ./makesure              # the goal named 'default' will be called if none provided
```
Yes, it's that simple.

However, that's not all. Goals can [declare](https://github.com/xonixx/makesure#depends_on) dependencies on other goals and makesure will take this into account when executing. This behavior is very close to the original `make`. A goal can also declare [a condition that it has already been reached](https://github.com/xonixx/makesure#reached_if). In this case, the goal body (the corresponding shell script) will no longer be executed. This simple mechanism makes it very convenient and declarative to express the idempotent logic of work. In other words, to speed up the build, since what has already been done will not be repeated. This feature has been inspired by ideas from Ansible.

This was the introduction. Now I want to focus on highlighting the design process of one of the features of this tool.

## Designing `@define`

Let's imagine that we will be designing the ability to define global variables that are available to all goals.

Well, something like

```shell
@define VERSION='1.2.3'
@goal built
   echo "Building $VERSION ..."
@goal tested
   echo "Testing $VERSION ..."
```

Initially, I wanted to design this part in the most general way. So, I decided that the tool will have the concept of prelude - this is a script that comes before all `@goal` declarations. The purpose of this script will be to initialize global variables. 

Something like

```shell
# prelude starts
if [ -f version.txt ]
then
   @define VERSION=`cat version.txt`
else
   @define VERSION='0.0.1'
fi
# prelude ends
@goal built
   echo "Building $VERSION ..."
```

The idea was to get closer in functionality to `make` without introducing a separate programming language, but to rely on the familiar shell.

A couple of important moments. First, note that under the hood, each of the `@goal` scripts runs in a separate shell process. This is done on purpose to eliminate the possibility of dependencies through global variables between goals, which can make the execution logic more imperative and confusing. `make` in this sense behaves in a similar way, or rather even "worse" - there each line is executed in a separate shell.

Secondly, I wanted the prelude script to be executed only once, regardless of how many goals would be executed in the process.

Obviously, the initialization script can be resource-intensive, say

```shell
@define VERSION="$(curl -s http://domain/version.txt)"
```

Thirdly, it should be possible to override the value of the variable at startup, like so

```
./makesure built -D VERSION=0.0.2
```

The first and second points don't mix well. This excludes the simple possibility of mixing in a prelude script at the beginning of each `@goal` script as an execution model.

As a result, the solution was nevertheless found. Every occurrence of `@defile VAR=val` was replaced under the hood with something like `VAR=val; echo "VAR='$VAR'" >> /tmp/makesure_values` and implicitly prefixed each `@goal` script with `. /tmp/makesure_values`.

There were some additional nuances associated with the implementation of the third point, but they are not too significant to mention.

Somehow it worked, but I was not 100% happy. It's kind of inelegant or something. Temporary files are obviously not good for the performance. Plus you need to do additional gestures to clean them up.

Regarding speed, on systems where [/dev/shm](https://superuser.com/a/45509/682392) is present (all modern Linuxes?) it has been used instead of `/tmp`. macOS - ☹️ - it's not supported there.

Regarding the guarantee of cleaning up temporary files - the test suite [has been modified](https://github.com/xonixx/makesure/blob/v0.9.14/Makesurefile#L77) in such a way as to crash if, for some reason, the garbage was not removed.

---

As is usually the case, a fresh perspective from someone not previously involved in the project can be very valuable.

At some point I received a [pull-request](https://github.com/xonixx/makesure/pull/81/files) with a proposal to optimize this part of the logic. The participant suggested to apply simpler logic without temporary files. For a while I was a bit confused. How did I not think of this solution before? However, plunging into some memories, I realized that my solution was not accidental.

The fact is that according to my plan there should have been an opportunity to do so

```shell
A=Hello              # invisible to goals
@define B="$A world" # visible to goals
```

According to my idea, this is achieved by the fact that already "calculated" `@define`-values get into the `/tmp/makesure_values` file.

And this fundamentally does not work in the method proposed by the participant.

What was my surprise when I [found](https://github.com/xonixx/makesure/pull/81#issuecomment-974904922) that this case does not work with my implementation either!

My first impulse was to fix this problem and cover this case with the missing tests.

However, instead I [thought hard](https://github.com/xonixx/makesure/pull/81#issuecomment-975958930).
It turns out that this is a function that even I myself (the author and main user of the tool) do not use in my scripts. Otherwise, I would have already discovered this problem.

But what if we completely remove the concept of prelude as an arbitrary script in front of the goals? Leave only `@define`?
Why not? After all, [less is more](https://en.wikipedia.org/wiki/Minimalism#Software_and_UI_design), and [worse is better](https://en.wikipedia.org/wiki/Worse_is_better).

Here are a few thoughts that guided me:

- This feature is not widely used (or not used at all) and has implementation bugs
- We don't know how to properly use this functionality yet. It may be misused/abused.
- Introduces uncertainty. If such complex initialization logic is needed, why not use a separate `@goal initialized` goal for that?
- Complicates the implementation and makes it less productive due to the use of temporary files.

*And in general, when developing a product or library, it is very important to implement the minimum possible functionality, and exactly the one that users need now. Quite often, developers are tempted to add some obvious improvements and features that are not critical and/or are redundant, simply because it seems simple. Moreover, for the same reason, it is often useful to explicitly exclude certain features/use cases. Because you can always add them later if there is an explicit request from users. Removing some kind of unsuccessful feature can be much more problematic.*

So I've decided. We cut down the concept of prelude, leaving only the possibility of `@define`.

---

However, the questions do not end there.

- Perhaps it also makes sense to rework the syntax:
    - `@define VAR='hello'` (like now) vs
    - `@define VAR 'hello'` (more consistent with the syntax of other directives)
    - Allow or disallow strings with double quotes? In other words, do we want to support variable substitution:
        - `@define W=world`
        - `@define HW="Hello $W!"`
- Implementation
    - pass-through to shell (as it is now)
        - Flexibility with variable substitution, but harder with validation
    - or manual parsing
        - More difficult to implement, but more control in the validation of uninitialized variables; if necessary, we can disable shell functions, for example `@define A="$(curl https://google.com)"`

The fact is that the current implementation, as mentioned above, is based on literally passing everything that comes after the word `@define` to execution in the shell. And this means that you can write
```shell
@define echo 'Hello'
```
and it won't throw an error, but it will do some unauthorized nonsense.

If you try to add a simple regular expression to match `VARNAME=`, then this is easy to get around

```shell
@define A=aaa echo 'Hello' # echo command will be called with environment variable A
```

Naturally, I would like to prohibit such "opportunities".

We have a dilemma. Either we refuse to pass to the shell and add an ad-hoc parser for this directive, or we have what we have.

A custom parser would be a good option if it weren't for the extreme complexity that needs to be added.

Do you know how many ways you can define a variable with the value `hello world` in Bash?

```shell
H=hello\ world
H='hello world'
H=$'hello world'
H="hello world"
W=world
H="hello $W"
H=hello\ $W
H='hello '$W
H='hello'\ $W
H=$'hello '"world"
H='hello'$' world'
H=$'hello'\ $'world'
H='hello'$' '"world"
H='hello world';
H="hello world" # with comment
H=$'hello world'    ;            # with semicolon, spaces and comments
# etc.
```

And that's not all the options!

Why is the extra implementation complexity unacceptable? Because one of the fundamental principles that I put into the basis of this tool is [worse is better](https://en.wikipedia.org/wiki/Worse_is_better). This means that ease of implementation and the minimum size of the utility are more preferable than rich functionality.


You may ask: why rely on bash syntax at all? Why not introduce your own limited syntax, say something like this:

{% raw %}
```shell
@define W  'world'
@define HW 'hello {{W}}'
```
{% endraw %}

The idea is tempting, but not without flaws. It introduces a complication of the mental complexity of the instrument.

The thing is that the tool is designed in such a way that its syntax is completely within the syntax of the shell. This is extremely handy as you can choose the shell highlight for `Makesurefile` in your IDE and [it will work](https://github.com/xonixx/makesure/blob/main/Makesurefile)! But this also means that it is necessary that all syntactic constructions carry the same meaning as in the shell. Obviously, the logic of value substitution in the hypothetical lightweight syntax does not correspond to the shell model and the user will have to know this additionally.

In general, removing the possibility of variable substitution would also be an option. But it turns out that the few who already use makesure, myself included, are already [relying](https://github.com/xonixx/makesure/pull/81#issuecomment-976174461) on this feature.

The result of painful reflections was a compromise solution. We still pass the string to the shell for execution, but before that we validate it with a carefully written [regular expression](https://github.com/xonixx/makesure/blob/v0.9.16/makesure.awk#L154). Yes, I know that [parsing with regular expressions is bad manners](https://stackoverflow.com/questions/1732348/regex-match-open-tags-except-xhtml-self-contained-tags/1732454#1732454). But we don't parse! We only cut off invalid inputs, and the shell parses. An interesting point to note. It appears that this regular expression is stricter than the shell parser:

```shell
@define VERSION=1.2.3      # makesure won't accept
@define VERSION='1.2.3'    # OK

@define HW=${HELLO}world   # makesure won't accept
@define HW="${HELLO}world" # OK
```

Which I find even a plus, as it is more consistent.

Overall, this directive is well covered with tests - both [what should be parsed](https://github.com/xonixx/makesure/blob/v0.9.16/tests/16_define_validation.sh) and [what shouldn't](https://github.com/xonixx/makesure/blob/v0.9.16/tests/16_define_validation_error.sh).

---

So let's summarize. We designed a feature. Then we redesigned it, while being able to simplify and reduce the code, speed it up and add additional checks.

If you are interested, I invite you to try out the [makesure](https://github.com/xonixx/makesure) utility in your projects.
The more so as it doesn't require installation [(how is that?)](https://github.com/xonixx/makesure#installation) and is [very portable](https://github.com/xonixx/makesure#os).