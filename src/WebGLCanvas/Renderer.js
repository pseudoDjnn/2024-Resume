import * as THREE from 'three'
import WebGLCanvas from "./WebGLCanvas";

export default class Renderer {
  constructor() {

    this.webglCanvas = new WebGLCanvas()
    this.canvas = this.webglCanvas.canvas
    this.sizes = this.webglCanvas.sizes
    this.scene = this.webglCanvas.scene
    this.camera = this.webglCanvas.camera

    this.setInstance()

    // console.log('this is the renderer')
  }

  setInstance() {
    this.instance = new THREE.WebGLRenderer({
      canvas: this.canvas,
      antialias: true,
      alpha: true
    })
    this.instance.toneMapping = THREE.ReinhardToneMapping
    this.instance.setSize(this.sizes.width, this.sizes.height)
    this.instance.setPixelRatio(this.sizes.pixelRatio)
    // console.log(this.instance)
  }

  resize() {
    this.instance.setSize(this.sizes.width, this.sizes.height)
    this.instance.setPixelRatio(this.sizes.pixelRatio)
  }

  update() {
    this.instance.render(this.scene, this.camera.instance)
  }
}