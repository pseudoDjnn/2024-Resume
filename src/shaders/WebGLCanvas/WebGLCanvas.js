import Sizes from "./Utils/Sizes"
import Time from "./Utils/Time"

export default class WebGLCanvas {
  constructor(canvas) {

    // Global access
    window.webglCanvas = this

    // Options
    this.canvas = canvas
    // console.log(this.canvas)

    // Setup
    this.sizes = new Sizes()
    this.time = new Time()


    // Sizes resize event
    this.sizes.on('resize', () => {
      this.resize()

      // console.log('this is now working')
    })

    // console.log('this works')

    // Time tick event
    this.time.on('tick', () => {
      this.update()
    })
  }

  resize() {
    // console.log('this work for the resize')
  }

  update() {
    // console.log('update the experience')
  }

}