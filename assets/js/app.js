// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import LiveSocket from "phoenix_live_view";

// Hover Functionality JS hooks
// TODO: needs add each dom have its own handler
let Hooks = {};
Hooks.ToggleContent = {
  mounted() {
    this.el.addEventListener("mouseenter", e => {
      document.getElementById("content").style.visibility = "hidden";
    });
    this.el.addEventListener("mouseleave", e => {
      document.getElementById("content").style.visibility = "visible";
    });
  }
};

const liveSocket = new LiveSocket("/live", { hooks: Hooks });
liveSocket.connect();
