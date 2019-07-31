# Hammoc Demo

[![Build Status](https://travis-ci.com/hammoc-app/live_view_demo.svg?branch=master)](https://travis-ci.com/hammoc-app/live_view_demo)

This is my entry in [Phoenix Phrenzy](https://phoenixphrenzy.com), showing off what [Phoenix](https://phoenixframework.org/) and [LiveView](https://github.com/phoenixframework/phoenix_live_view) can do.

![Hammoc Demo](assets/static/images/hammoc.svg "Hammoc Demo")

## Development

Initial setup:

  * You'll need Elixir, Erlang and Node.js. If you use the [asdf version manager](https://github.com/asdf-vm/asdf) and install the [relevant plugins](https://asdf-vm.com/#/plugins-all?id=plugin-list), you can install the versions specified in `.tool-versions` with `asdf install`.
  * Install Docker to run the databases
    * On macOS, install [Docker Desktop for Mac](https://docs.docker.com/docker-for-mac/install/).
    * On Ubuntu, install the [`docker-ce` apt package](https://docs.docker.com/install/linux/docker-ce/ubuntu/).
  * Start databases with `docker-compose up -d`
  * Create and migrate your database with `mix ecto.setup`

After each git pull:

  * Install dependencies with `mix deps.get`
  * Migrate your database with `mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`

To start your Phoenix server:

  * (Re-)start databases with `docker-compose up -d`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
