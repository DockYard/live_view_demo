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

function isBrowserCompatible(){
  const svg = document.createElement('SVG')

  // Using "visibility: hidden; position: absolute" instead of "display: none;" because
  // even Chrome will not report an accurate character count on the textPath if we
  // use display: none
  svg.innerHTML = '<svg style="visibility: hidden; position: absolute; height: 0; width: 0;"><text><textPath>test</textPath></text></svg>'
  document.body.appendChild(svg)

  return 4 == svg.querySelector('textPath').getNumberOfChars()
}

Hooks.CurrentText = {
  mounted() {
    if(isBrowserCompatible()){
      const textPaths = Array.from(document.querySelectorAll('textPath'))
      this.pushEvent('load_char_data', computeCharacterPointsAndRotations(textPaths))
    } else {
      this.pushEvent('bail_out_browser_incompatible')
    }
  }
}

window.addEventListener('keydown', function(e) {
  e.keyCode == 32 && e.preventDefault()
})

let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks })
liveSocket.connect()
