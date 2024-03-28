export default class WebGLCanvas {
  constructor(canvas) {

    // Global access
    window.webglCanvas = this

    // Options
    this.canvas = canvas
    // console.log(this.canvas)

    // console.log('this works')
  }
}