# Dialyzer for Elixir

Do you want to read more about how everything is implemented? Go here then: [docs](doc/README.md)

---

Elixir has matured a lot in the last years! And in the newer versions we are continually seeing an increasing focus on
project productivity tools, like error diffs, mix xref, exception blame and code formatter.

Although all of this is already amazing, and it allows us to write nice and correct (mosty) programs, elixir is still
a dynamic programming language, and even though it let's you quickly iterate from an idea to a prototype,
it doesn't make you feel so confident when working on a large scale project.

This is why we need some form of static typing, and altough we cannot change elixir, we can leverage a statical analysis tool
like dialyzer (but you probably already know this, since you are here! :D).

# Goals

The problem of using dialyzer directly is that we cannot leverage its power to offer to the developer a great experience.
Let me explain briefly over that: dialyzer is awesome, but it has some major flaws:
- Incredibly slow (order of minutes, no good!)
- Cryptic error messages
- Somewhat hard to configure correctly (not as straightforward as one would like it to be)

The proposed solution here is to develop a mix task that should resolve all the flaws showed above:
- Incremental analysis (we want seconds, at worst)
- First class error messages (ansii colored, long/short variant, elm/credo style)
- Dead easy to run (`mix dialyzer` should be used in the 99% of the cases)

I know this will not be easy and I'll encounter a lot of problems on the road, so any help and/or
suggestion is really welcomed!

The final goal is to merge this project into elixir itself! :D
(For some more infos, go here: https://summerofcode.withgoogle.com/projects/#4978058864361472)

# Difference from other projects

**First of all, I would like to thank the contributors of all the existing projects that already exists! Without you this would be even more difficult than what already is.**

The goal of this project is to learn how the other existing solutions tried to implement dialyzer for elixir,
take the good parts and implement them, then take the bad parts and try to improve over them.

There are already a few libraries for interfacing with dialyzer, the problem is that some of them are
not maintained anymore, even though they had some good ideas at their core:

- https://github.com/jeremyjh/dialyxir:
  Most popular project, has been developed constantly over the years and now has some nice features.

  **pro**:
    - Most of the features implemented
    - Good implementation

  **cons**:
    - Some technical debt over the past versions/years
    - Missing incremental compilation(*1)

- (*1) https://github.com/JakeBecker/elixir-ls:
  Really nice language server developed by Jake, used mainly with the companion plugin for VSCode. He implemented an incrementally compiled version of dialyzer into elixirLS.

  **pro**:
    - Incremental compilation

  **cons**:
    - Using some internal components of dialyzer

- Other notable projects:
  - https://github.com/Comcast/dialyzex: Good project level, but still missing some major features
  - https://github.com/fishcakez/dialyze: Seems to integrate some type of incremental compilation, needs more investigation from my side

# Why

Soooo... Here are some general points to answer to your nice questions:
- **Why not contribute to another project**:

  Since the goal of this project is to be merged into core elixir, it's better to start from scratch and develop everything
  with this goal in mind. We do not want technical debt and need pretty much a lot of features that currently are divided into
  separated projects.

  On top of this, I can act freely and break things when I want, the dream of any developer :D

- **Don't you have a social life? Why are you doing this to yourself!**:

  First of all: I know it sounds strange, but I really enjoy creating stuff! And it gets even better when you are paid to do so!
  For those who don't know, this is going to be a project under the Google Summer of Code (https://summerofcode.withgoogle.com/).

  Second: I'll be working on something I've really wanted for a long time to be present in elixir!

  Third: This summer I'm gonna experiment with being a digital nomad while working:
  I would like to travel to Istanbul, Bali and Hanoi (we'll see about other places, but if you are from one of those, write me!
  We can always meet for a beer and chat about how awesome elixir is - and else! :D)
