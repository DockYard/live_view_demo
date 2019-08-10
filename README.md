# TypoKart

The Typo~Krat~Kart project is an attempt to develop a fun typing game in elixir using LiveView, themed as a multi-player kart racing game. We have no idea how this will turn out, but as long as it's fun then who cares! Contributors to the starting line.

The goal of the project will be to enable focused opportunities for people in the Seattle area to collaborate on writing Elixir and LiveView code coming from different skill levels over the next two months.

## MVP Primary Development Objectives

More detailed requirements will be worked out as part of an [upcoming session](https://github.com/elixir-sea/typo_kart/wiki/In-Person-Availability#upcoming-sessions). Issues will be created to represent pieces of work that anybody can assign and work on.

  * Build out a procedural course generator. Given a random seed, develop a racing course with twists and turns that creates a loop.

  * Develop mechanics for getting around the map that involves typing. This will involve controlling acceleration and velocity based on typing speed, with some dynamic handicapping to keep the game fun for people of different skill levels.

* Add components to the game that allow players to interact with each other in destructive ways. Make the game fun.

## Development Instructions

For development, you'll need Elixir, Erlang and Node.js. If you use the [asdf version manager](https://github.com/asdf-vm/asdf) and install the [relevant plugins](https://asdf-vm.com/#/plugins-all?id=plugin-list), you can install the versions specified in `.tool-versions` with `asdf install`.

## Contributing

Anyone in the Seattle area can be a contributor. Ask in the #seattle or the #typo_kart channel in the [Elixir-Lang slack group](https://elixir-slackin.herokuapp.com/).

We are using a simple Pull Request model. Create a new branch based on master for you additions and then create a PR against master.

Pull requests require a code review from at least one other contributor, but then can be merged to master by anyone. The goal is to get new features into master as quickly as possible, so the reviewer should just merge once approved.

## LiveView Documentation

Since LiveView isn't yet published to hex, there are no hosted docs yet. I find it useful to have the HTML documentation
so here are the instructions for compiling the docs locally:

```bash
git clone git@github.com:phoenixframework/phoenix_live_view.git
cd phoenix_live_view
mix deps.get
env MIX_ENV=docs mix docs
open doc/index.html
```

## Deployment

How you deploy your app is up to you. A couple of the easiest options are:

- Heroku ([instructions](https://hexdocs.pm/phoenix/heroku.html))
- [Gigalixir](https://gigalixir.com/) (doesn't limit number of connections)

## The Usual README Content

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
