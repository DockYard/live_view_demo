// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

const Hooks = {}

function getCourse(){
  return document.getElementById('course')
}

function getCurrentTextPath() {
  return document.getElementById(
    getCourse()
      .getAttribute('data-current-text-path-id')
  )
}

function getCurCharIndex(){
  return +getCourse().getAttribute('data-current-char-index')
}

Hooks.CurrentText = {
  adjustRotation() {
    const textPath = getCurrentTextPath()
    const currentCharIndex = getCurCharIndex()
    const point = textPath.getStartPositionOfChar(currentCharIndex)
    const charRotation = textPath.getRotationOfChar(currentCharIndex)

    this.pushEvent('adjust_rotation', {
      currentCharPoint: {
        x: point.x, y: point.y
      },
      currentCharRotation: charRotation
    })
  },
  updated() {
    this.adjustRotation()
  },
  mounted() {
    this.adjustRotation()
  }
}

let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks })
liveSocket.connect()
