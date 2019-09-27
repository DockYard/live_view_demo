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

function computeCharacterPointsAndRotations(textPaths = []){
  return textPaths
  .map(t => {
    const pathChars = []
    for(let i=0; i<t.getNumberOfChars(); i++){
      const svgPoint = t.getStartPositionOfChar(i)
      const rotation = t.getRotationOfChar(i)

      pathChars.push({
        point: {
          x: svgPoint.x,
          y: svgPoint.y
        },
        rotation
      })
    }
    return pathChars
  })
}

Hooks.CurrentText = {
  mounted() {
    const textPaths = Array.from(document.querySelectorAll('textPath'))
    this.pushEvent('load_char_data', computeCharacterPointsAndRotations(textPaths))
  }
}

window.addEventListener('keydown', function(e) {
  e.keyCode == 32 && e.preventDefault()
})

let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks })
liveSocket.connect()
