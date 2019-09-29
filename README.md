# (App Name Here)

This is [Rocket Insights'](https:/rocketinsights.com) entry in [Phoenix Phrenzy](https://phoenixphrenzy.com), showing off what [Phoenix](https://phoenixframework.org/) and [LiveView](https://github.com/phoenixframework/phoenix_live_view) can do.

![Flame of Life](assets/static/images/logo.gif "Flame of Life")

# Phrenzy Instructions

Fork this repo and start build an application! See [Phoenix Phrenzy](https://phoenixphrenzy.com) for details.

Note: for development, you'll need Elixir, Erlang and Node.js. If you use the [asdf version manager](https://github.com/asdf-vm/asdf) and install the [relevant plugins](https://asdf-vm.com/#/plugins-all?id=plugin-list), you can install the versions specified in `.tool-versions` with `asdf install`.


## Deployment

The app is hosted on  [Gigalixir](https://gigalixir.com/): [Flame of
Life](https://flame-of-life.gigalixirapp.com/)

## Conway's Game of Life
This is the Phoenix implementation of [Conway's Game of
Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life), a cellular
automation game where the evolution is set based on the initial state and
doesn't require input from the viewer.

This implementation of Game of Life offers some features that highlight
LiveView's technology, none needing page reloads, any javascript, or even resetting
of the template:

* selecting a template, or using the default random template
* selecting the speed that the cells will move
* cell color by RGB values
* pausing of the game
* resetting the game

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
