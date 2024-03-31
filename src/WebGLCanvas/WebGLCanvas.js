import * as THREE from 'three'
import Sizes from "./Utils/Sizes"
import Time from "./Utils/Time"
import Camera from './Camera'
import Renderer from './Renderer'
import World from './World/World'

let instance = null

export default class WebGLCanvas {
  constructor(canvas) {

    if (instance) {
      return instance
    }

    instance = this

    // Global access
    // window.webglCanvas = this

    // Options
    this.canvas = canvas
    // console.log(this.canvas)

    // Setup
    this.sizes = new Sizes()
    this.time = new Time()
    this.scene = new THREE.Scene()
    this.camera = new Camera()
    this.renderer = new Renderer()
    this.world = new World()


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

    this.camera.resize()
    this.renderer.resize()

    // console.log('this work for the resize')
  }

  update() {

    this.camera.update()
    this.world.update()
    this.renderer.update()

    // console.log('update the experience')
  }

}